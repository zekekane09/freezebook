// import 'package:list_all_videos/list_all_videos.dart';
// import 'package:list_all_videos/model/video_model.dart';
//
// class VideoLoader {
//   Future<List<String>> loadAllVideos() async {
//     ListAllVideos videoLister = ListAllVideos();
//     List<VideoDetails> videoDetailsList = await videoLister.getAllVideosPath();
//
//     // Extract the file paths from VideoDetails
//     List<String> videoPaths = videoDetailsList.map((video) => video.videoPath).toList(); // Adjust this line based on the actual property name
//     return videoPaths;
//   }
// }