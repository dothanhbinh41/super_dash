// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:super_dash/game/view/game_view.dart';
import 'package:super_dash/gen/assets.gen.dart';
import 'package:super_dash/main.dart';
import 'package:super_dash/score/input_initials/view/initials_form_view.dart';

class GameInfoInputDialog extends StatefulWidget {
  const GameInfoInputDialog({super.key});

  static PageRoute<void> route() {
    return HeroDialogRoute(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const GameInfoInputDialog(),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => GameInfoInputDialogState();
}

class GameInfoInputDialogState extends State<GameInfoInputDialog> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final regex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
  String? errorPhone;
  String? errorName;
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final current = await leaderboardRepository.currentLeaderboardEntry();
    if (current == null) {
      return;
    }
    phoneController.text = current.phoneNumber;
    nameController.text = current.playerInitials;
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      border: Border.all(color: Colors.white24),
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: Assets.images.dashWins.image(width: 230),
          ),
          Column(
            children: [
              const Text(
                'Nhập số điện thoại và nick name của\n bạn cho bảng xếp hạng',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Nick name',
                textAlign: TextAlign.center,
              ),
              InitialFormField(
                hint: 'Nick name',
                controller: nameController,
                onChanged: (p0) {
                  if (p0.length > 30) {
                    setState(() {
                      errorName = 'Tên quá dài';
                    });
                    return;
                  }

                  if (p0.length > 3 && p0.length <= 30) {
                    setState(() {
                      errorName = '';
                    });
                  }

                  nameController.text =
                      p0.replaceAll(RegExp('A-Z0-9a-z '), '').trim();
                },
              ),
              Visibility(
                visible: errorName != null && errorName!.isNotEmpty,
                child: ErrorTextWidget(errorName ?? ''),
              ),
              const SizedBox(height: 16),
              const Text(
                'Số điện thoại',
                textAlign: TextAlign.center,
              ),
              InitialFormField(
                hint: 'Số điện thoại',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (p0) {
                  if (regex.hasMatch(p0)) {
                    setState(() {
                      errorPhone = '';
                    });
                  }
                },
              ),
              Visibility(
                visible: errorPhone != null && errorPhone!.isNotEmpty,
                child: ErrorTextWidget(errorPhone ?? ''),
              ),
              const SizedBox(height: 24),
              GameElevatedButton(
                label: 'Chơi ngay',
                onPressed: createUser,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> createUser() async {
    if (phoneController.text.isEmpty) {
      setState(() {
        errorPhone = 'Số điện thoại không được bỏ trống';
      });
      return;
    }

    if (!regex.hasMatch(phoneController.text)) {
      setState(() {
        errorPhone = 'Số điện thoại sai định dạng';
      });
      return;
    }

    if (nameController.text.length <= 3) {
      setState(() {
        errorName = 'Vui lòng nhập nickname';
      });
      return;
    }

    if (nameController.text.length > 30) {
      setState(() {
        errorName = 'Tên quá dài';
      });
      return;
    }

    final res = await leaderboardRepository.createUser(
      LeaderboardEntryData(
          playerInitials: nameController.text,
          phoneNumber: phoneController.text,
          score: 0,
          rank: 0),
    );
    if (res == false) {
      setState(() {
        errorName = 'Tên đã tồn tại';
      });
      return;
    }
    await Navigator.of(context).push(Game.route());
  }
}
