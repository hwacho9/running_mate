import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/profile/edit_profile_view.dart';
import 'package:running_mate/viewmodels/profile_view_model.dart';

class ProfileHeader extends StatelessWidget {
  final String nickname;
  final int followingCount;
  final int followersCount;
  final String currentUserId; // 로그인된 사용자 UID
  final String profileUserId; // 보고 있는 프로필의 사용자 UID
  final VoidCallback? onEditProfile; // 프로필 수정 버튼 콜백
  final VoidCallback? onFollow; // 팔로우 버튼 콜백
  final bool isFollowing; // 팔로우 상태

  const ProfileHeader({
    super.key,
    required this.nickname,
    required this.followingCount,
    required this.followersCount,
    required this.currentUserId,
    required this.profileUserId,
    this.onEditProfile,
    this.onFollow,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMyProfile = currentUserId == profileUserId;
    final profileViewModel = context.watch<ProfileViewModel>();

    print("isMyProfile: $isMyProfile");
    print("isFollowing: $isFollowing");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("Following: $followingCount"),
                    const SizedBox(width: 16),
                    Text("Followers: $followersCount"),
                  ],
                ),
                const SizedBox(height: 12),
                // 버튼: 수정 또는 팔로우
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isMyProfile
                        ? () {
                            // Navigate to EditProfileView
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileView(),
                              ),
                            );
                          }
                        : () async {
                            await profileViewModel.toggleFollowStatus(
                                currentUserId, profileUserId);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMyProfile
                          ? Colors.blueAccent // 내 프로필 수정 버튼 색상
                          : (isFollowing
                              ? Colors.grey // 언팔로우 상태 색상
                              : Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isMyProfile
                          ? "プロファイルを編集" // 내 프로필일 경우
                          : (isFollowing ? "フォロー中" : "フォローする"),
                      style: TextStyle(
                          color: isMyProfile
                              ? Colors.white // 내 프로필 수정 버튼 색상
                              : (isFollowing
                                  ? Colors.white // 언팔로우 상태 색상
                                  : Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
