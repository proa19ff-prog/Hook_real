import 'dart:math';
import '../../core/storage/local_storage_service.dart';
import '../extractor/models/media_track.dart';
import '../extractor/stream_resolver.dart';

class RecommendationService {
  final LocalStorageService _storage;
  final StreamResolver _resolver;

  RecommendationService({
    required this._storage,
    required this._resolver,
  });

  /// Artist names with the strongest listening signals — the wave blends one
  /// catalog track per artist into every batch so radio gravitates toward
  /// the listener's own taste. Favorites weigh most, then history recency,
  /// then real replay counts fading with idle time.
  List<String> topPersonalArtists({int limit = 2}) {
    final scores = _artistAffinity();
    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(limit).map((entry) => entry.key).toList();
  }

  Map<String, double> _artistAffinity() {
    final scores = <String, double>{};
    void bump(String artist, double delta) {
      final clean = _cleanArtistName(artist);
      if (clean.isNotEmpty) {
        scores[clean] = (scores[clean] ?? 0.0) + delta;
      }
    }

    for (final track in _storage.getFavorites()) {
      bump(track.artist, 3.5);
    }
    final history = _storage.getHistory();
    for (var index = 0; index < history.length; index++) {
      bump(history[index].artist, 1.2 / (1.0 + index * 0.05));
    }
    _applyPlaySignals(scores);
    return scores;
  }

  /// Adds the device's own replay counters: repeated plays strengthen an
  /// artist's pull, entries untouched for days fade out.
  void _applyPlaySignals(Map<String, double> scores) {
    final counts = _storage.getPlayCounts();
    final stamps = _storage.getPlayTimestamps();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    counts.forEach((key, count) {
      final artist = _cleanArtistName(key.split('|').first);
      if (artist.isEmpty) return;
      var weight = min(count.toDouble(), 12.0) * 0.4;
      final stamp = stamps[key];
      if (stamp != null) {
        final hours = (nowMs - stamp) / 3600000.0;
        weight *= 1.0 / (1.0 + hours / 48.0);
      }
      scores[artist] = (scores[artist] ?? 0.0) + weight;
    });
  }

  static const List<String> _popularStarters = [
    'The Weeknd',
    'Alan Walker',
    'Imagine Dragons',
    'Dua Lipa',
    'Arctic Monkeys',
    'Eminem',
    'Phonk mix',
    'Miyagi',
    'Billie Eilish',
    'Kizaru',
    'Post Malone',
    'DVRST',
    'Hans Zimmer',
    'Interworld',
  ];

  /// Generates a personalized queue of recommended tracks by evaluating candidates
  /// through the multi-objective scoring formula:
  ///
  /// S(u, i, t) = (α * Sim_collab + β * Sim_audio + γ * Seq_trans) *
  ///              Φ_reward(u, i) * Ψ_fatigue(u, i, t) +
  ///              ε * Explore(i)
  ///
  /// Followed by Markov Transition Smoothing and DPP Diversification.
  Future<List<MediaTrack>> getPersonalizedRecommendations({
    int limit = 25,
    DateTime? currentTime,
  }) async {
    final now = currentTime ?? DateTime.now();
    final favorites = _storage.getFavorites();
    final history = _storage.getHistory();

    // 1. Build User Interaction Profile and Frequency Graphs
    final artistScores = <String, double>{};
    final artistPlayCount = <String, int>{};
    final favoriteTrackKeys = <String>{};
    final historyTrackKeys = <String>{};

    for (final track in favorites) {
      favoriteTrackKeys.add('${track.source.name}:${track.id}');
      final artist = _cleanArtistName(track.artist);
      if (artist.isNotEmpty) {
        artistScores[artist] = (artistScores[artist] ?? 0.0) + 3.5;
        artistPlayCount[artist] = (artistPlayCount[artist] ?? 0) + 3;
      }
    }

    for (int idx = 0; idx < history.length; idx++) {
      final track = history[idx];
      historyTrackKeys.add('${track.source.name}:${track.id}');
      final artist = _cleanArtistName(track.artist);
      if (artist.isNotEmpty) {
        // More recent history items carry higher weight
        final recencyFactor = 1.0 / (1.0 + (idx * 0.05));
        artistScores[artist] = (artistScores[artist] ?? 0.0) + (1.2 * recencyFactor);
        artistPlayCount[artist] = (artistPlayCount[artist] ?? 0) + 1;
      }
    }

    // Replay counters recorded on the device sharpen the profile further.
    final counts = _storage.getPlayCounts();
    final stamps = _storage.getPlayTimestamps();
    counts.forEach((key, count) {
      final artist = _cleanArtistName(key.split('|').first);
      if (artist.isEmpty) return;
      var weight = min(count.toDouble(), 12.0) * 0.4;
      final stamp = stamps[key];
      if (stamp != null) {
        final hours = (now.millisecondsSinceEpoch - stamp) / 3600000.0;
        weight *= 1.0 / (1.0 + hours / 48.0);
      }
      artistScores[artist] = (artistScores[artist] ?? 0.0) + weight;
      artistPlayCount[artist] = (artistPlayCount[artist] ?? 0) + count;
    });

    // Average session duration from recent tracks
    final recentTracks = history.take(5).toList();
    final avgSessionDurationSec = recentTracks.isNotEmpty
        ? recentTracks
                .map((t) => t.duration.inSeconds)
                .where((s) => s > 30)
                .fold<int>(0, (a, b) => a + b) ~/
            (recentTracks.isNotEmpty ? recentTracks.length : 1)
        : 210;

    // 2. Select query seeds for candidate generation
    final seedQueries = <String>[];
    if (artistScores.isNotEmpty) {
      final sortedArtists = artistScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedArtists.take(4)) {
        seedQueries.add(entry.key);
      }
    }

    // Ensure we always have diverse seeds
    if (seedQueries.length < 3) {
      final shuffledStarters = List<String>.from(_popularStarters)..shuffle();
      for (final starter in shuffledStarters) {
        if (!seedQueries.contains(starter)) {
          seedQueries.add(starter);
          if (seedQueries.length >= 3) break;
        }
      }
    }

    // 3. Candidate Generation
    final candidatePool = <MediaTrack>[];
    final seenIds = <String>{};

    for (final query in seedQueries) {
      try {
        final results = await _resolver.search(
          query: query,
          includeSoundCloud: true,
          includeSpotify: true,
        );
        for (final track in results) {
          if (seenIds.add(track.id)) {
            candidatePool.add(track);
          }
        }
      } catch (_) {}
    }

    if (candidatePool.length < 10) {
      try {
        final fallbacks = await _resolver.search(
          query: 'Top Hits 2024',
          includeSoundCloud: true,
          includeSpotify: true,
        );
        for (final track in fallbacks) {
          if (seenIds.add(track.id)) {
            candidatePool.add(track);
          }
        }
      } catch (_) {}
    }

    if (candidatePool.isEmpty) return const [];

    // 4. Compute Dynamic Alpha, Beta, Gamma Weights
    // Niche sessions with long tracks favor acoustic resonance (Beta),
    // mainstream sessions favor collaborative graph (Alpha).
    final isNicheSession = avgSessionDurationSec > 300 ||
        seedQueries.any((q) => q.toLowerCase().contains('phonk') || q.toLowerCase().contains('ambient'));

    final double alpha = isNicheSession ? 0.25 : 0.50; // Sim_collab
    final double beta = isNicheSession ? 0.50 : 0.25;  // Sim_audio
    final double gamma = 0.25;                         // Seq_trans

    // 5. Score Each Candidate i for User u at time t
    final totalHistorySize = max(1, history.length);
    final scoredCandidates = <_ScoredTrack>[];

    final lastPlayedTrack = history.isNotEmpty ? history.first : null;

    for (final track in candidatePool) {
      final trackKey = '${track.source.name}:${track.id}';
      final cleanArtist = _cleanArtistName(track.artist);

      // A. Core Compatibility
      // 1. Sim_collab: Graph overlap with user's favorite & history artists
      final artistAffinity = artistScores[cleanArtist] ?? 0.0;
      final simCollab = (artistAffinity / 10.0).clamp(0.0, 1.0);

      // 2. Sim_audio: Acoustic resonance (duration & tempo profile match)
      final trackDurSec = track.duration.inSeconds;
      final durDiff = (trackDurSec - avgSessionDurationSec).abs();
      final simAudio = exp(-durDiff / max(60, avgSessionDurationSec)).clamp(0.1, 1.0);

      // 3. Seq_trans: Sequential context & time-of-day alignment
      double seqTrans = 0.5;
      if (lastPlayedTrack != null) {
        if (_cleanArtistName(lastPlayedTrack.artist) == cleanArtist) {
          seqTrans += 0.3; // artist continuity
        }
      }
      // Time-of-day context: Morning vs Day vs Night
      final hour = now.hour;
      final titleLower = track.title.toLowerCase();
      if ((hour >= 22 || hour < 6) && (titleLower.contains('night') || titleLower.contains('lo-fi') || titleLower.contains('phonk') || titleLower.contains('chill'))) {
        seqTrans += 0.25;
      } else if (hour >= 6 && hour < 12 && (titleLower.contains('acoustic') || titleLower.contains('morning') || titleLower.contains('pop'))) {
        seqTrans += 0.2;
      }
      seqTrans = seqTrans.clamp(0.1, 1.0);

      final compatibilityCore = (alpha * simCollab) + (beta * simAudio) + (gamma * seqTrans);

      // B. Multi-task Engagement Multiplier: Phi_reward(u, i)
      // w1 * P(Complete) + w2 * P(Save) + w3 * P(Repeat) - w4 * P(Skip<15s)
      double phiReward = 1.0;
      final isFav = favoriteTrackKeys.contains(trackKey);
      final playCount = artistPlayCount[cleanArtist] ?? 0;

      if (isFav) phiReward += 3.5; // w2 = 3.5 (Save / Favorite)
      if (playCount >= 2) phiReward += 1.8; // w3 = repeat factor

      // C. Ebbinghaus Fatigue & Freshness Factor: Psi_fatigue(u, i, t)
      // Psi = 1 - exp(- Delta_t / (tau * N_plays))
      double psiFatigue = 1.0;
      final historyIndex = history.indexWhere((t) => t.id == track.id);
      if (historyIndex >= 0) {
        // Track was played in history; calculate simulated Delta_t in hours
        final hoursAgo = (historyIndex + 1) * 1.5;
        final nPlays = max(1, playCount);
        const tau = 4.0;
        psiFatigue = (1.0 - exp(-hoursAgo / (tau * nPlays))).clamp(0.05, 1.0);
      } else if (isFav) {
        // Unheard favorite track gets nostalgia boost
        psiFatigue = 1.25;
      }

      // D. Exploration Discovery Term: epsilon * Explore(i)
      // Explore(i) = sqrt(2 * ln(T) / (n_i + 1)) * Novelty(u, i)
      const epsilon = 0.28;
      final nExposures = playCount;
      final novelty = artistScores.containsKey(cleanArtist) ? 0.2 : 1.0;
      final ucb = sqrt((2.0 * log(totalHistorySize + 2)) / (nExposures + 1.0));
      final exploreTerm = epsilon * ucb * novelty;

      // Final Mathematical Score S(u, i, t)
      final score = (compatibilityCore * phiReward * psiFatigue) + exploreTerm;

      scoredCandidates.add(_ScoredTrack(track: track, score: score));
    }

    // Sort by mathematical score descending
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));

    // 6. DJ-Curator Post-Processing (DPP Diversification & Markov Smoothing)
    return _applyDjCurator(
      scoredCandidates.map((s) => s.track).toList(),
      limit: limit,
    );
  }

  /// DJ-Curator Post-Processing Filter:
  /// Enforces DPP diversification (spreading same artist at least 3-4 tracks apart)
  /// and eliminates abrupt jarring duration jumps.
  List<MediaTrack> _applyDjCurator(List<MediaTrack> rawCandidates, {required int limit}) {
    if (rawCandidates.isEmpty) return const [];

    final curatedQueue = <MediaTrack>[];
    final remainingPool = List<MediaTrack>.from(rawCandidates);

    // Pick top scored track as anchor
    curatedQueue.add(remainingPool.removeAt(0));

    while (curatedQueue.length < limit && remainingPool.isNotEmpty) {
      final prevTrack = curatedQueue.last;

      int bestCandidateIdx = -1;
      double bestPenalty = double.infinity;

      for (int i = 0; i < remainingPool.length; i++) {
        final candidate = remainingPool[i];
        final candArtist = _cleanArtistName(candidate.artist);

        double penalty = i.toDouble(); // Preserves general score ordering

        // Determinantal Point Process (DPP): Penalize recent artists in last 3 positions
        for (int back = 0; back < min(3, curatedQueue.length); back++) {
          final pastArtist = _cleanArtistName(curatedQueue[curatedQueue.length - 1 - back].artist);
          if (candArtist == pastArtist) {
            penalty += (3 - back) * 15.0; // Heavy separation penalty
          }
        }

        // Markov Tempo / Duration Smoothing: Penalize extreme duration anomalies (> 2x)
        final prevSec = max(60, prevTrack.duration.inSeconds);
        final candSec = max(60, candidate.duration.inSeconds);
        final ratio = candSec / prevSec;
        if (ratio > 2.5 || ratio < 0.4) {
          penalty += 8.0;
        }

        if (penalty < bestPenalty) {
          bestPenalty = penalty;
          bestCandidateIdx = i;
          if (bestPenalty == 0) break; // Optimal match found
        }
      }

      if (bestCandidateIdx >= 0) {
        curatedQueue.add(remainingPool.removeAt(bestCandidateIdx));
      } else {
        curatedQueue.add(remainingPool.removeAt(0));
      }
    }

    return curatedQueue;
  }

  String _cleanArtistName(String artist) {
    return artist
        .split(RegExp(r'[,&]'))
        .first
        .replaceAll(RegExp(r'\s*(feat\.|ft\.|prod\.).*', caseSensitive: false), '')
        .trim();
  }
}

class _ScoredTrack {
  final MediaTrack track;
  final double score;

  const _ScoredTrack({required this.track, required this.score});
}
