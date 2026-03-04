import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/ProfileScreen/public_profile_screen.dart';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/MVVM/view_model/invite_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class InviteUserList extends StatefulWidget {
  final int eventId;

  const InviteUserList({super.key, required this.eventId});

  @override
  State<InviteUserList> createState() => _InviteUserListState();
}

class _InviteUserListState extends State<InviteUserList> {
  final authViewModel = Get.put(AuthViewModel());
  final inviteViewModel = Get.put(InviteViewModel());

  @override
  void initState() {
    super.initState();
    inviteViewModel.setEventId(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -10.h,
            right: -10.w,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (authViewModel.isLoading.value) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.blueColor));
                    } else if (authViewModel.error.isNotEmpty) {
                      return Center(
                          child: Text(authViewModel.error.value,
                              style: const TextStyle(color: Colors.white70)));
                    }

                    final currentUserId = authViewModel.currentUser['userId'];
                    final filteredUsers = authViewModel.users
                        .where((user) => user.userId != currentUserId)
                        .toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Text(
                          'No users available',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 12.sp),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 1.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(2.h),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.h),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: ListTile(
                                onTap: () {
                                  HapticUtils.light();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PublicProfileScreen(id: user.userId),
                                    ),
                                  );
                                },
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 0.5.h),
                                leading: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.blueColor
                                          .withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white10,
                                    backgroundImage: CachedNetworkImageProvider(
                                      'https://eventgo-live.com${user.profileImageUrl}',
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.name ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  user.email ?? '',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.white38,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Obx(() {
                                  final isInvited = inviteViewModel
                                      .selectedUserIds
                                      .contains(user.userId);
                                  return GestureDetector(
                                    onTap: () {
                                      HapticUtils.selection();
                                      inviteViewModel
                                          .toggleInvite(user.userId!);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                        color: isInvited
                                            ? Colors.white
                                                .withValues(alpha: 0.1)
                                            : AppColors.blueColor
                                                .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(2.h),
                                        border: Border.all(
                                          color: isInvited
                                              ? Colors.white24
                                              : AppColors.blueColor
                                                  .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        isInvited ? 'Invited' : 'Invite',
                                        style: TextStyle(
                                          color: isInvited
                                              ? Colors.white70
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                // 🔷 Invite button section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: Obx(() => inviteViewModel.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.blueColor)
                      : SizedBox(
                          width: double.infinity,
                          height: 6.5.h,
                          child: GestureDetector(
                            onTap: () {
                              HapticUtils.buttonPress();
                              inviteViewModel.sendInvites();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.blueColor,
                                    AppColors.blueColor.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(4.h),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blueColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Invite Selected Friends',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.navigation();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Invite Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}
