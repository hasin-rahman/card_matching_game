import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Card Matching Game",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CardMatchingGame(),
      ),
    );
  }
}

class GameState extends ChangeNotifier {
  List<CardModel> _cards = [];
  CardModel? _firstSelected;
  CardModel? _secondSelected;
  bool _isProcessing = false;

  GameState() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> icons = ['🍎', '🍌', '🍒', '🍇', '🍓', '🍉', '🍍', '🥭'];
    icons = [...icons, ...icons];
    icons.shuffle(Random());
    _cards = List.generate(icons.length, (index) => CardModel(icons[index]));
    notifyListeners();
  }

  List<CardModel> get cards => _cards;

  void selectCard(CardModel card) async {
    if (_isProcessing || card.isMatched || card.isFaceUp) return;

    card.flip();
    notifyListeners();

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _secondSelected = card;
      _isProcessing = true;
      await Future.delayed(Duration(milliseconds: 800));
      if (_firstSelected!.icon == _secondSelected!.icon) {
        _firstSelected!.isMatched = true;
        _secondSelected!.isMatched = true;
      } else {
        _firstSelected!.flip();
        _secondSelected!.flip();
      }
      _firstSelected = null;
      _secondSelected = null;
      _isProcessing = false;
      notifyListeners();
    }
  }
}

class CardModel {
  final String icon;
  bool isFaceUp = false;
  bool isMatched = false;

  CardModel(this.icon);

  void flip() {
    if (!isMatched) {
      isFaceUp = !isFaceUp;
    }
  }
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Matching Game")),
      body: Center(
        child: Consumer<GameState>(
          builder: (context, gameState, child) {
            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gameState.cards.length,
              itemBuilder: (context, index) {
                return CardWidget(card: gameState.cards[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<GameState>(context, listen: false).selectCard(card);
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationYTransition(turns: animation, child: child);
        },
        child:
            card.isFaceUp || card.isMatched
                ? Container(
                  key: ValueKey(card.icon),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 239, 194, 194),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 33, 243, 37),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(card.icon, style: TextStyle(fontSize: 40)),
                  ),
                )
                : Container(
                  key: ValueKey("back"),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 53, 178, 232),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class RotationYTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> turns;

  RotationYTransition({required this.child, required this.turns});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turns,
      builder: (context, child) {
        final angle = turns.value * pi;
        return Transform(
          transform: Matrix4.rotationY(angle),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
