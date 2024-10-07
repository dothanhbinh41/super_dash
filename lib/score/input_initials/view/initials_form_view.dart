import 'package:app_ui/app_ui.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_dash/l10n/l10n.dart';
import 'package:super_dash/score/input_initials/formatters/formatters.dart';
import 'package:super_dash/score/score.dart';

class InitialsFormView extends StatefulWidget {
  const InitialsFormView({super.key, this.hint});
  final String? hint;

  @override
  State<InitialsFormView> createState() => _InitialsFormViewState();
}

class _InitialsFormViewState extends State<InitialsFormView> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        InitialFormField(
          hint: widget.hint,
          onChanged: (value) {
            _onInitialChanged(context, value);
          },
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const CircularProgressIndicator(color: Colors.white)
        else
          GameElevatedButton(
            label: l10n.enter,
            onPressed: () {},
          ),
      ],
    );
  }

  void _onInitialChanged(BuildContext context, String value) {
    var text = value;
    if (text == emptyCharacter) {
      text = '';
    }
    // context.read<ScoreBloc>().add(ScoreInitialsUpdated(character: text));
  }
}

class InitialFormField extends StatefulWidget {
  const InitialFormField(
      {this.onChanged,
      super.key,
      this.hint,
      this.keyboardType,
      this.controller});
  final TextInputType? keyboardType;
  final String? hint;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  @override
  State<InitialFormField> createState() => _InitialFormFieldState();
}

class _InitialFormFieldState extends State<InitialFormField> {
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [
          Color(0x3DD0F7FB),
          Color(0x3D05B5CB),
        ],
      ),
      border: Border.all(
        color: const Color(0xFF77F3B7),
        width: 2,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: decoration,
      child: TextFormField(
        controller: widget.controller,
        showCursor: true,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        style: textTheme.displaySmall?.copyWith(fontSize: 28),
        decoration: InputDecoration(
          border: InputBorder.none,
          alignLabelWithHint: true,
          hintText: widget.hint,
          hintStyle: textTheme.titleLarge?.copyWith(
            fontSize: 28,
            color: const Color(0x4077F3B7),
          ),
        ),
        textAlign: TextAlign.center,
        onChanged: (value) {
          widget.onChanged?.call(value);
        },
      ),
    );
  }
}

class ErrorBody extends StatelessWidget {
  const ErrorBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox(height: 40),
        ErrorTextWidget(l10n.scoreSubmissionErrorMessage),
        const SizedBox(height: 32),
        GameElevatedButton.icon(
          label: l10n.playAgain,
          icon: const Icon(Icons.refresh, size: 16),
          onPressed: () {
            context.flow<ScoreState>().complete();
          },
        ),
      ],
    );
  }
}

class ErrorTextWidget extends StatelessWidget {
  const ErrorTextWidget(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          FontAwesomeIcons.circleExclamation,
          color: Color(0xFFF48B8B),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
