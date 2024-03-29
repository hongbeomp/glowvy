import 'dart:io';
import 'dart:math';

import 'package:Dimodo/common/colors.dart';
import 'package:Dimodo/common/constants.dart';
import 'package:Dimodo/common/popups.dart';
import 'package:Dimodo/common/widgets.dart';
import 'package:Dimodo/generated/i18n.dart';
import 'package:Dimodo/models/product/review_model.dart';
import 'package:Dimodo/models/user/userModel.dart';
import 'package:Dimodo/screens/edit_birthyear_page.dart';
import 'package:Dimodo/screens/edit_gender_page.dart';
import 'package:Dimodo/screens/edit_name_page.dart';
import 'package:Dimodo/screens/edit_skin_issues_page.dart';
import 'package:Dimodo/screens/edit_skin_type_page.dart';
import 'package:Dimodo/screens/setting.dart';
import 'package:Dimodo/widgets/setting_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage();

  @override
  State<StatefulWidget> createState() {
    return EditProfilePageState();
  }
}

class EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool enabledNotification = true;
  UserModel userModel;
  final picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
  }

  Future uploadImage(context) async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        isLoading = true;
      });
      if (pickedFile != null) {
        await userModel.uploadProfilePicture(File(pickedFile.path));
      } else {
        print('No image selected.');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Popups.failMessage(
          'the permission is not granted, plesae grand access to the albums in settings',
          context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    imageCache.clear();
    PaintingBinding.instance.imageCache.clear();

    kRateMyApp.init().then((_) {});

    return Scaffold(
        appBar: AppBar(
            brightness: Brightness.light,
            elevation: 0,
            leading: backIcon(context),
            backgroundColor: Colors.white,
            title: Text(S.of(context).accounts, style: textTheme.headline3)),
        backgroundColor: kDefaultBackground,
        body: Consumer<UserModel>(builder: (context, userModel, child) {
          final user = userModel.user;
          final firebaseUser = userModel.firebaseUser;
          print('user profile photo: ${user.picture}');
          return Container(
            child: ListView(
              children: <Widget>[
                Builder(
                  builder: (context) => SettingCard(
                      color: kWhite,
                      title: 'Ảnh đại diện',
                      trailingWidget: isLoading
                          ? kIndicator()
                          : user?.picture == null
                              ? Image.asset(
                                  'assets/icons/default-avatar.png',
                                )
                              : ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.picture +
                                        '?v=${ValueKey(Random().nextInt(100))}',
                                    key: ValueKey(Random().nextInt(100)),
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      onTap: () async {
                        await uploadImage(context);
                        await Provider.of<ReviewModel>(context, listen: false)
                            .updateReviewerInfo(userModel.user);
                      }),
                ),
                SettingCard(
                  color: kWhite,
                  title: 'Tên',
                  trailingText: user.fullName,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => EditNamePage())),
                ),
                SettingCard(
                  color: kWhite,
                  title: 'Giới tính',
                  trailingText: user.gender,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const EditGenderPage())),
                ),
                const SizedBox(height: 7),
                SettingCard(
                  color: kWhite,
                  title: 'Năm sinh',
                  trailingText:
                      user.birthYear != null ? user.birthYear.toString() : '',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              EditBirthyearPage())),
                ),
                SettingCard(
                    color: kWhite,
                    title: 'Loại da',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const EditSkinTypePage())),
                    trailingText: user.skinType ?? ''),
                SettingCard(
                  color: kWhite,
                  title: 'Tình trạng da',
                  showDivider: false,
                  trailingText:
                      user.skinIssues != null && user.skinIssues.isNotEmpty
                          ? user.skinIssues.join(', ')
                          : '',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const EidtSkinIssuesPage())),
                  // trailingText: userModel.user.fullName,
                ),
                const SizedBox(height: 7),
                SettingCard(
                  color: kWhite,
                  title: 'Cài đặt tài khoản',
                  showDivider: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => SettingPage()),
                    // trailingText: userModel.user.fullName,
                  ),
                )
              ],
            ),
          );
        }));
  }
}
