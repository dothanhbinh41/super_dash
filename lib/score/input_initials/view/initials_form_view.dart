import 'package:app_ui/app_ui.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_dash/l10n/l10n.dart';
import 'package:super_dash/score/input_initials/formatters/formatters.dart';
import 'package:super_dash/score/score.dart';

class InitialsFormView extends StatefulWidget {
  const InitialsFormView({super.key});

  @override
  State<InitialsFormView> createState() => _InitialsFormViewState();
}

class _InitialsFormViewState extends State<InitialsFormView> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<ScoreBloc, ScoreState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.initialsStatus == InitialsFormStatus.failure) {
          return const _ErrorBody();
        }
        return Column(
          children: [
            _InitialFormField(
              onChanged: (value) {
                _onInitialChanged(context, value);
              },
            ),
            const SizedBox(height: 24),
            if (state.initialsStatus == InitialsFormStatus.loading)
              const CircularProgressIndicator(color: Colors.white)
            else
              GameElevatedButton(
                label: l10n.enter,
                onPressed: () {
                  context.read<ScoreBloc>().add(const ScoreInitialsSubmitted());
                },
              ),
            const SizedBox(height: 16),
            if (state.initialsStatus == InitialsFormStatus.blacklisted)
              _ErrorTextWidget(l10n.initialsBlacklistedMessage)
            else if (state.initialsStatus == InitialsFormStatus.invalid)
              _ErrorTextWidget(l10n.initialsErrorMessage),
          ],
        );
      },
    );
  }

  void _onInitialChanged(BuildContext context, String value) {
    var text = value;
    if (text == emptyCharacter) {
      text = '';
    }
    context.read<ScoreBloc>().add(ScoreInitialsUpdated(character: text));
  }
}

class _InitialFormField extends StatefulWidget {
  const _InitialFormField({
    required this.onChanged,
  });

  final void Function(String) onChanged;

  @override
  State<_InitialFormField> createState() => _InitialFormFieldState();
}

class _InitialFormFieldState extends State<_InitialFormField> {
  late final TextEditingController controller =
      TextEditingController.fromValue(lastValue);

  bool hasFocus = false;
  TextEditingValue lastValue = const TextEditingValue(
    text: emptyCharacter,
    selection: TextSelection.collapsed(offset: 1),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.watch<ScoreBloc>();
    final blacklisted =
        bloc.state.initialsStatus == InitialsFormStatus.blacklisted;
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [
          Color(0x3DD0F7FB),
          Color(0x3D05B5CB),
        ],
      ),
      border: Border.all(
        color: blacklisted ? const Color(0xFFF3777E) : const Color(0xFF77F3B7),
        width: 2,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(left: 48, right: 48),
      decoration: decoration,
      child: TextFormField(
        controller: controller,
        showCursor: true,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.phone,
        style: textTheme.displayMedium,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        textAlign: TextAlign.center,
        onChanged: (value) {
          widget.onChanged(value);
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox(height: 40),
        _ErrorTextWidget(l10n.scoreSubmissionErrorMessage),
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

class _ErrorTextWidget extends StatelessWidget {
  const _ErrorTextWidget(this.text);

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
