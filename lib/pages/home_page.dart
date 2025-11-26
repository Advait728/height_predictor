import 'package:flutter/material.dart';
import 'package:height_prediction/pages/results.dart';
import 'dart:math';

class AnimatedGradient extends StatefulWidget {
  final Widget child;
  final bool active;
  final Duration duration;
  final Alignment begin;
  final Alignment end;

  const AnimatedGradient({
    super.key,
    required this.child,
    required this.active,
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  @override
  State<AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _controller.forward(from: Random().nextDouble());

    _controller.repeat(reverse: true);

    _animation = AlignmentTween(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              begin: _animation.value,
              end: Alignment.centerRight,
              colors: const [Color(0xFFB388FF), Color(0xFF8BC6EC)],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBoy = true;
  bool _isIn = false;
  bool _showResult = false;

  double? _mum;
  double? _dud;
  double? _predictedHeight;

  final List<DropdownMenuEntry<double>> _dropdownItemsCm = List.generate(90, (
    index,
  ) {
    int value = index + 125;
    return DropdownMenuEntry<double>(
      value: value.toDouble(),
      label: "$value cm",
    );
  });

  final List<DropdownMenuEntry<double>> _dropdownItemsIn = List.generate(50, (
    index,
  ) {
    int value = index + 48;
    return DropdownMenuEntry<double>(
      value: value.toDouble(),
      label: "${value ~/ 12}'${value % 12}\"",
    );
  });

  final List<int> dispHeight = List.generate(100, (index) => index + 1);

  double cmToIn(double cm) => cm / 2.54;
  double inToCm(double inch) => inch * 2.54;

  double returnExpectedHeight(double mom, double dad) {
    if (!_isIn) {
      mom = cmToIn(mom);
      dad = cmToIn(dad);
      if (_isBoy) {
        return 2.54 * ((mom + dad + 5) / 2);
      } else {
        return 2.54 * ((mom + dad - 5) / 2);
      }
    }

    if (_isBoy) {
      return (mom + dad + 5) / 2;
    } else {
      return (mom + dad - 5) / 2;
    }
  }

  Widget genderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBoy = true;

                  if (_showResult && _mum != null && _dud != null) {
                    _predictedHeight = returnExpectedHeight(_mum!, _dud!);
                  }
                });
              },
              child: AnimatedGradient(
                active: _isBoy,
                duration: const Duration(seconds: 10),
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isBoy) const Icon(Icons.check, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Boy",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isBoy ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBoy = false;
                  if (_showResult && _mum != null && _dud != null) {
                    _predictedHeight = returnExpectedHeight(_mum!, _dud!);
                  }
                });
              },
              child: AnimatedGradient(
                active: !_isBoy,
                duration: const Duration(seconds: 10),
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.female, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Girl",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: !_isBoy ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget unitSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isIn == false) return;

                setState(() {
                  if (_mum != null) _mum = inToCm(_mum!).roundToDouble();
                  if (_dud != null) _dud = inToCm(_dud!).roundToDouble();

                  if (_predictedHeight != null) {
                    _predictedHeight = inToCm(_predictedHeight!);
                  }

                  _isIn = false;
                });
              },
              child: AnimatedGradient(
                active: !_isIn,
                duration: const Duration(seconds: 10),
                begin: Alignment.topRight,
                end: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Cm",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: !_isIn ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isIn == true) return;

                setState(() {
                  if (_mum != null) _mum = cmToIn(_mum!).roundToDouble();
                  if (_dud != null) _dud = cmToIn(_dud!).roundToDouble();

                  if (_predictedHeight != null) {
                    _predictedHeight = cmToIn(_predictedHeight!);
                  }

                  _isIn = true;
                });
              },
              child: AnimatedGradient(
                active: _isIn,
                duration: const Duration(seconds: 10),
                begin: Alignment.topRight,
                end: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isIn ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final screenH = MediaQuery.of(context).size.height;

    double scale(double s) => s * (screenH * 0.0013);

    final isIn = _isIn;
    final h = _predictedHeight ?? 0;

    String display = isIn
        ? "${(h ~/ 12)}'${(h % 12).round()}\""
        : "${h.round()} cm";

    return Container(
      width: double.infinity,
      key: const ValueKey("resultCard"),

      margin: EdgeInsets.only(top: scale(8), bottom: scale(8)),

      padding: EdgeInsets.symmetric(vertical: scale(8), horizontal: scale(8)),

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(scale(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: scale(6)),
            child: Text(
              "PREDICTED ADULT HEIGHT",
              style: TextStyle(
                fontSize: scale(16),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),

          SizedBox(height: scale(8)),

          Text(
            display,
            style: TextStyle(
              fontSize: scale(44),
              fontWeight: FontWeight.w900,
              color: Color(0xFFB388FF),
            ),
          ),

          SizedBox(height: scale(5)),

          Text(
            "EXPECTED RANGE",
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.3,
              fontSize: scale(13),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: scale(5)),

          Text(
            isIn
                ? () {
                    int low = (_predictedHeight! - 5).round();
                    int high = (_predictedHeight! + 5).round();
                    return "${low ~/ 12}'${low % 12}\"  -  ${high ~/ 12}'${high % 12}\"";
                  }()
                : "${(_predictedHeight! - 5).round()} - ${(_predictedHeight! + 5).round()} cm",
            style: TextStyle(
              height: 1.4,
              fontSize: scale(15),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60.0,
        title: Padding(
          padding: EdgeInsetsGeometry.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Height Predictor',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Calculate your child\'s predicted adult height',
                style: TextStyle(fontSize: 14.0, color: Colors.black54),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.account_tree),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 110),
                  genderSelector(),
                  const SizedBox(height: 20),
                  unitSelector(),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 2),
                        child: Text(
                          "Select mother height",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownMenu<double>(
                          key: ValueKey("mother_$_isIn"),
                          trailingIcon: const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            size: 20,
                          ),
                          width: double.infinity,
                          menuHeight: 200,
                          initialSelection: _mum,
                          onSelected: (height) {
                            if (height != null) {
                              setState(() {
                                _mum = height.toDouble();
                              });
                            }
                          },
                          dropdownMenuEntries: _isIn
                              ? _dropdownItemsIn
                              : _dropdownItemsCm,
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Color.fromARGB(255, 200, 168, 255),
                              // Color(0xFFB388FF)
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1000),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 255, 255),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 2),
                        child: Text(
                          "Select father height",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownMenu<double>(
                          key: ValueKey("father_$_isIn"),
                          width: double.infinity,
                          menuHeight: 200,
                          initialSelection: _dud,
                          onSelected: (height) {
                            if (height != null) {
                              setState(() {
                                _dud = height.toDouble();
                              });
                            }
                          },
                          trailingIcon: const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            size: 20,
                          ),
                          dropdownMenuEntries: _isIn
                              ? _dropdownItemsIn
                              : _dropdownItemsCm,
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Color.fromARGB(255, 200, 168, 255),
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1000),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFB388FF),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        side: BorderSide.none,
                        fixedSize: Size.fromHeight(50),
                      ),
                      child: Text(
                        "Calculate",
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        if (_mum != 0 &&
                            _dud != 0 &&
                            _mum != null &&
                            _dud != null) {
                          setState(() {
                            _predictedHeight = returnExpectedHeight(
                              _mum!,
                              _dud!,
                            );
                            _showResult = true;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: EdgeInsets.all(16),
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Invalid inputs!",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Please enter values for parent heights",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _showResult
                        ? _buildResultCard()
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
