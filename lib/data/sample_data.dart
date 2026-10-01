import '../models/post.dart';
import '../models/story.dart';
import 'dart:math';

/// Sample data for demonstration
class SampleData {
  // Master list of ALL valid asset images (Corrupt 29-byte files removed)
  static const List<String> _allImages = [
    'assets/images/10.31.01_pm.jpg',
    'assets/images/aesthetic_2.jpg',
    'assets/images/img_10.jpg',
    'assets/images/img_11.jpg',
    'assets/images/img_12.jpg',
    'assets/images/img_13.jpg',
    'assets/images/img_2b.jpg',
    'assets/images/img_2.jpg',
    'assets/images/img_3b.jpg',
    'assets/images/img_3.jpg',
    'assets/images/img_4b.jpg',
    'assets/images/img_4.jpg',
    'assets/images/img_5.jpg',
    'assets/images/img_6.jpg',
    'assets/images/img_7.jpg',
    'assets/images/img_8.jpg',
    'assets/images/img_9.jpg',
    'assets/images/aesthetic_misc.jpg',
    'assets/images/nature_night_sky.jpg',
    'assets/images/bali_indonesia_poster_picture_metal_print_paint_by_enzoken_art_displate.jpg',
    'assets/images/68k_black_people.jpg',
    'assets/images/abstract_people.jpg',
    'assets/images/alone_car.jpg',
    'assets/images/amandla_stenberg_20_afro-americana_e_dinamarquesa.jpg',
    'assets/images/amandla_premiere.jpg',
    'assets/images/ayra_starr-2.jpg',
    'assets/images/ayra_starr.jpg',
    'assets/images/bielefeld_dup.jpg',
    'assets/images/christ_dup.jpg',
    'assets/images/christian_yhwh_wallpaper.jpg',
    'assets/images/dave_psychodrama_was_the_album_i_needed_it_to_be_british_gq.jpg',
    'assets/images/discover_10_spectacular_must-see_destinations_in_berlin.jpg',
    'assets/images/fotospots_die_sch_nsten_orte_zum_fotografieren_weltweit.jpg',
    'assets/images/heidelberg_germany.jpg',
    'assets/images/heidelberg_dup.jpg',
    'assets/images/portrait_nyc.jpg',
    'assets/images/instagramspots_hier_findest_du_die_besten_fotospots_in_berlin_-.jpg',
    'assets/images/jojadoja_jojadoja.jpg',
    'assets/images/jessica_alba-2.jpg',
    'assets/images/jessica_alba.jpg',
    'assets/images/jessica_alba_10.31.01_pm.jpg',
    'assets/images/jesus_walking_on_water_powerful_christian_artwork_of_faith_and_miracles.jpg',
    'assets/images/kendrick_lamar.jpg',
    'assets/images/sunset_wallpaper.jpg',
    'assets/images/makeup_dup.jpg',
    'assets/images/meet_jorja_smith_the_soul_singer_who_turned_down_drake.jpg',
    'assets/images/messi_wallpaper.jpg',
    'assets/images/n1_dup.jpg',
    'assets/images/n2_dup.jpg',
    'assets/images/n3_dup.jpg',
    'assets/images/n4_dup.jpg',
    'assets/images/n5_2.jpg',
    'assets/images/n5_dup.jpg',
    'assets/images/n6_dup.jpg',
    'assets/images/nascer_do_sol.jpg',
    'assets/images/nathalie_emmanuel.jpg',
    'assets/images/nico_vinz_-_album_am_i_wrong.jpg',
    'assets/images/nusa_penida_travel_guide_how_to_visit_nusa_penida_from_bali.jpg',
    'assets/images/olivia_dean_-_messy.jpg',
    'assets/images/ps5_dup.jpg',
    'assets/images/passau_by_night_affiches_et_impressions_par_christian_marold_-_printler.jpg',
    'assets/images/pin_on_wanderlust.jpg',
    'assets/images/product_delays_spending_cuts_how_apple_has_managed_to_avoid_layoffs_so_far.jpg',
    'assets/images/romance_cd_album_mixtape_cover_design_templat_postermywall.jpg',
    'assets/images/romanticizing_life.jpg',
    'assets/images/selena_gomez.jpg',
    'assets/images/the_audacity_by_j_cole.jpg',
    'assets/images/the_beautiful_apple_park.jpg',
    'assets/images/ratatouille_musical.jpg',
    'assets/images/university_of_applied_sciences_and_university_of_bielefeld.jpg',
    'assets/images/voyage_en_afrique.jpg',
    'assets/images/wallpaper_ideas.jpg',
    'assets/images/ai.jpg',
    'assets/images/chase_infiniti.jpg',
    'assets/images/football_in_favelas.jpg',
    'assets/images/hi_c_-_kino_der_toten.jpg',
    'assets/images/jesus_wallpaper_by_world_s_love_-_download_on_zedge_c1dc.jpg',
    'assets/images/jorja_smith.jpg',
    'assets/images/jorja_smithhhh.jpg',
    'assets/images/the_beauty_of_geneva.jpg',
    'assets/images/tylaa.jpg',
    'assets/images/disney_stitch.jpg',
    'assets/images/amazing_astronomy_50_of_the_most_captivating_astronomy_pictures.jpg',
    'assets/images/whale.jpg',
    'assets/images/king_of_kings.jpg',
  ];

  /// Each creator is a fixed name + avatar pair.
  /// This ensures every post by the same author always shows the same profile picture.
  static const List<Map<String, String>> _creators = [
    {'name': 'Chanda Mwale',   'avatar': 'assets/images/ayra_starr.jpg'},
    {'name': 'Mutale Banda',   'avatar': 'assets/images/jessica_alba.jpg'},
    {'name': 'Lubasi Phiri',   'avatar': 'assets/images/nathalie_emmanuel.jpg'},
    {'name': 'Natasha Zimba',  'avatar': 'assets/images/selena_gomez.jpg'},
    {'name': 'Melody Mbewe',   'avatar': 'assets/images/jorja_smith.jpg'},
    {'name': 'Patrick Ngoma',  'avatar': 'assets/images/tylaa.jpg'},
    {'name': 'Esther Howard',  'avatar': 'assets/images/amandla_premiere.jpg'},
    {'name': 'Guy Hawkins',    'avatar': 'assets/images/kendrick_lamar.jpg'},
    {'name': 'Robert Fox',     'avatar': 'assets/images/makeup_dup.jpg'},
    {'name': 'Jane Cooper',    'avatar': 'assets/images/ayra_starr-2.jpg'},
    {'name': 'Cameron Williamson', 'avatar': 'assets/images/jessica_alba-2.jpg'},
    {'name': 'Brooklyn Simmons',   'avatar': 'assets/images/jessica_alba_10.31.01_pm.jpg'},
  ];

  static const List<String> _titles = [
    'Golden Hour', 'Morning Vibes', 'Nature Walk', 'City Lights', 
    'Cozy Corner', 'Weekend Mood', 'Art Gallery', 'Coffee Break',
    'Dreamscape', 'Urban Jungle', 'Road Trip', 'Self Care',
    'Hidden Gem', 'Sunset Lover', 'Vintage Find', 'Studio Day'
  ];
  
  static const List<String> _captions = [
    'Loving this vibe ✨', 'Details matter 🔍', 'Cannot get enough 😍',
    'Current mood ☁️', 'POV: You are here 📍', 'Simply beautiful 🌿',
    'Moments like this 🕰', 'Obsessed! 🔥', 'Take me back ✈️',
    'Outfit details 👗', 'Close up 📸', 'Aesthetic goals 🎨'
  ];

  // Expose a subset or mix for random usage
  static List<String> get imageUrls => _allImages;

  // Cached posts — generated once, returned on every subsequent call.
  // Use getFreshPosts() or invalidateCache() when you need new data.
  static List<Post>? _cachedPosts;

  /// Clears the cached posts so the next call to samplePosts regenerates them.
  static void invalidateCache() {
    _cachedPosts = null;
  }

  static List<Post> get samplePosts {
    _cachedPosts ??= _generatePosts();
    return _cachedPosts!;
  }

  static List<Post> _generatePosts() {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final posts = <Post>[];

    for (int i = 0; i < _allImages.length; i++) {
      final image = _allImages[i];
      final isVideo = i % 7 == 0; // Every 7th is a "video"
      final isCarousel = i % 5 == 0 && !isVideo;
      final isGrid = i % 15 == 0 && !isVideo && !isCarousel; // Only on bigger tiles

      // Determine type
      PostType type = PostType.single;
      if (isVideo) type = PostType.video;
      else if (isCarousel) type = PostType.carousel;
      else if (isGrid) type = PostType.grid;

      // Determine aspect ratio - alternate between square and landscape
      // Use landscape format (1.5:1) for roughly every other post
      final isWide = i % 2 == 0;
      final aspectRatio = isWide ? 1.5 : 1.0;

      // For carousel/grid, pick random sub-images
      List<String> subImages = [];
      List<String> subCaptions = [];
      
      if (isCarousel || isGrid) {
        subImages = [image];
        // Add 3 random other images
        for (int j = 0; j < 3; j++) {
           subImages.add(_allImages[random.nextInt(_allImages.length)]);
        }
        
        // Generate captions for carousel
        if (isCarousel) {
          for (int k = 0; k < subImages.length; k++) {
            subCaptions.add(_captions[random.nextInt(_captions.length)]);
          }
        }
      }

      posts.add(Post(
        id: 'post_$i',
        imageUrl: image,
        title: _titles[random.nextInt(_titles.length)],
        authorName: _creators[i % _creators.length]['name']!,
        authorAvatar: _creators[i % _creators.length]['avatar']!,
        likes: 100 + random.nextInt(5000),
        comments: 10 + random.nextInt(200),
        saves: 5 + random.nextInt(100),
        tags: ['aesthetic', 'vibe', 'koala'],
        description: 'Exploring the aesthetic side of life ✨ #${i+1}',
        type: type,
        images: subImages,
        captions: subCaptions,
        aspectRatio: aspectRatio,
        isVideo: isVideo,
        videoDuration: isVideo ? Duration(seconds: 15 + random.nextInt(45)) : null,
        isPopular: random.nextBool() && random.nextBool(), // 25% chance
      ));
    }
    
    // Shuffle them so similar images (like all animals) aren't always grouped
    posts.shuffle(Random(DateTime.now().millisecondsSinceEpoch)); 
    return posts;
  }

  // Get fresh posts with different shuffle for refresh
  static List<Post> getFreshPosts() {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final posts = <Post>[];

    for (int i = 0; i < _allImages.length; i++) {
      final image = _allImages[i];
      final isVideo = i % 7 == 0;
      final isCarousel = i % 5 == 0 && !isVideo;
      final isGrid = i % 15 == 0 && !isVideo && !isCarousel;

      PostType type = PostType.single;
      if (isVideo) type = PostType.video;
      else if (isCarousel) type = PostType.carousel;
      else if (isGrid) type = PostType.grid;

      final isWide = i % 2 == 0;
      final aspectRatio = isWide ? 1.5 : 1.0;

      List<String> subImages = [];
      List<String> subCaptions = [];
      
      if (isCarousel || isGrid) {
        subImages = [image];
        for (int j = 0; j < 3; j++) {
           subImages.add(_allImages[random.nextInt(_allImages.length)]);
        }
        
        if (isCarousel) {
          for (int k = 0; k < subImages.length; k++) {
            subCaptions.add(_captions[random.nextInt(_captions.length)]);
          }
        }
      }

      posts.add(Post(
        id: 'post_$i',
        imageUrl: image,
        title: _titles[random.nextInt(_titles.length)],
        authorName: _creators[i % _creators.length]['name']!,
        authorAvatar: _creators[i % _creators.length]['avatar']!,
        likes: 100 + random.nextInt(5000),
        comments: 10 + random.nextInt(200),
        saves: 5 + random.nextInt(100),
        tags: ['aesthetic', 'vibe', 'koala'],
        description: 'Exploring the aesthetic side of life ✨ #${i+1}',
        type: type,
        images: subImages,
        captions: subCaptions,
        aspectRatio: aspectRatio,
        isVideo: isVideo,
        videoDuration: isVideo ? Duration(seconds: 15 + random.nextInt(45)) : null,
        isPopular: random.nextBool() && random.nextBool(),
      ));
    }
    
    // Use current time as seed for different shuffle each time
    posts.shuffle(Random(DateTime.now().millisecondsSinceEpoch)); 
    return posts;
  }

  static List<Category> get categories => [
    Category(
      id: '1',
      name: 'Aesthetic',
      imageUrl: _allImages[0],
      emoji: '✨',
    ),
    Category(
      id: '2',
      name: 'Fashion',
      imageUrl: _allImages[1],
      emoji: '👗',
    ),
    Category(
      id: '3',
      name: '90s Vibes',
      imageUrl: _allImages[2],
      emoji: '💿',
    ),
    Category(
      id: '4',
      name: 'Soft Life',
      imageUrl: _allImages[3],
      emoji: '🌸',
    ),
    Category(
      id: '5',
      name: 'Nature',
      imageUrl: _allImages[4],
      emoji: '🌿',
    ),
    Category(
      id: '6',
      name: 'Animals',
      imageUrl: _allImages[5],
      emoji: '🐆',
    ),
    Category(
      id: '7',
      name: 'Wallpapers',
      imageUrl: _allImages[6],
      emoji: '🎨',
    ),
  ];

  static UserProfile get currentUser => UserProfile(
    id: '1',
    username: 'koala_user',
    displayName: 'Aesthetic Vibes',
    avatarUrl: _creators[0]['avatar']!,
    coverUrl: _allImages[7],
    bio: 'Living the soft life in Lusaka 🌸✨',
    followers: 12500,
    following: 1200,
    posts: 234,
  );

  static List<Story> get sampleStories => [
    Story(
      id: '1',
      imageUrl: _allImages[8],
      timeAgo: '15m',
    ),
    Story(
      id: '2',
      imageUrl: _allImages[9],
      timeAgo: '20m',
    ),
    Story(
      id: '3',
      imageUrl: _allImages[10],
      timeAgo: '1h',
    ),
    Story(
      id: '4',
      imageUrl: _allImages[11],
      timeAgo: '2h',
    ),
    Story(
      id: '5',
      imageUrl: _allImages[12],
      timeAgo: '3h',
      isViewed: true,
    ),
    Story(
      id: '6',
      imageUrl: _allImages[13],
      timeAgo: '5h',
      isViewed: true,
    ),
  ];
}
