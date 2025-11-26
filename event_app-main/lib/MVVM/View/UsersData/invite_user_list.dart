import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/ProfileScreen/public_profile_screen.dart';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/MVVM/view_model/invite_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class InviteUserList extends StatefulWidget {
  final int eventId; // 🆕 receive eventId

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
    inviteViewModel.setEventId(widget.eventId); // 🆕 set eventId in ViewModel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: 7.h, left: 4.w, right: 4.w),
        child: Column(
          children: [
            // 🔷 Top bar
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                SizedBox(width: 15.w),
                Text(
                  'Invite Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // 🔷 Users list
            Expanded(
              child: Obx(() {
                if (authViewModel.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else if (authViewModel.error.isNotEmpty) {
                  return Center(child: Text(authViewModel.error.value));
                }

                // 🔷 Exclude current logged-in user
                final currentUserId = authViewModel.currentUser['userId'];
                final filteredUsers = authViewModel.users
                    .where((user) => user.userId != currentUserId)
                    .toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      'No users available',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfileScreen(id: user.userId),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.transparent,
                              backgroundImage: CachedNetworkImageProvider(
                                'https://eventgo-live.com${user.profileImageUrl}',
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name ?? '',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email ?? '',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              final isInvited = inviteViewModel.selectedUserIds.contains(user.userId);
                              return GestureDetector(
                                onTap: () => inviteViewModel.toggleInvite(user.userId!),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isInvited ? Colors.grey : AppColors.blueColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    isInvited ? 'Invited' : 'Invite',
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // 🔷 Invite Friends button
            Obx(() => inviteViewModel.isLoading.value
                ? CircularProgressIndicator()
                : ButtonWidget(
              text: 'Invite Friends',
              borderRadius: 4.h,
              textColor: AppColors.whiteColor,
              backgroundColor: AppColors.blueColor,
              onPressed: () {
                inviteViewModel.sendInvites();
              },
            )),
          ],
        ),
      ),
    );
  }
}
