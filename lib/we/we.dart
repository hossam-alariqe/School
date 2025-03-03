import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

// الثوابت الأصلية
const double kCardHeight = 225;
const double kCardWidth = 356;
const double kSpaceBetweenCard = 24;
const double kSpaceBetweenUnselectCard = 32;
const double kSpaceUnselectedCardToTop = 320;
const Duration kAnimationDuration = Duration(milliseconds: 245);

class CreditCardData {
  CreditCardData({
    required this.backgroundColor,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
  });
  
  final Color backgroundColor;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
}

class CardSelectionUI extends StatefulWidget {
  const CardSelectionUI({super.key});

  @override
  State<CardSelectionUI> createState() => _CardSelectionUIState();
}

class _CardSelectionUIState extends State<CardSelectionUI> {
  int? selectedCardIndex;
  final List<CreditCardData> cardData = [
    CreditCardData(
      backgroundColor: Colors.orange,
      cardNumber:"1",
      expiryDate: '12/25',
      cardHolderName: " اشراف المهندس عيسى الجماعي ",
      cvvCode: '123',
    ),
    CreditCardData(
      backgroundColor: Colors.grey.shade900,
      cardNumber: '5500 0000 0000 0004',
      expiryDate: '09/24',
      cardHolderName: 'التطبيق سهل وسلسل ومتجاوب مع المستخدم',
      cvvCode: '456',
    ),
    CreditCardData(
      backgroundColor: Colors.cyan,
      cardNumber: '3400 0000 0000 009',
      expiryDate: '03/26',
      cardHolderName: 'التواصل والدعم على الرقم 773022428',
      cvvCode: '789',
    ),
    CreditCardData(
      backgroundColor: Colors.blue,
      cardNumber: '6011 0000 0000 0004',
      expiryDate: '11/23',
      cardHolderName: 'تطبيق ادارة مدرسة صغيرة',
      cvvCode: '321',
    ),
    CreditCardData(
      backgroundColor: Colors.purple,
      cardNumber: '2223 0000 0000 0007',
      expiryDate: '07/27',
      cardHolderName:' م / حسام نبيل القباطي',
      cvvCode: '654',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: kAnimationDuration,
                height: _calculateTotalHeight(),
                width: MediaQuery.of(context).size.width,
              ),
              for (int i = 0; i < cardData.length; i++)
                _buildCreditCard(i),
              if (selectedCardIndex != null)
                Positioned.fill(
                  child: GestureDetector(
                    onVerticalDragStart: (_) => _unselectCard(),
                    onVerticalDragEnd: (_) => _unselectCard(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCard(int index) {
    final isSelected = index == selectedCardIndex;
    return AnimatedPositioned(
      top: _getCardTopPosition(index, isSelected),
      duration: kAnimationDuration,
      child: AnimatedScale(
        scale: _getCardScale(index, isSelected),
        duration: kAnimationDuration,
        child: GestureDetector(
          onTap: () => setState(() => selectedCardIndex = index),
          child: CreditCardWidget(
            cardNumber: cardData[index].cardNumber,
            expiryDate: cardData[index].expiryDate,
            cardHolderName: cardData[index].cardHolderName,
            cvvCode: cardData[index].cvvCode,
            showBackView: false,
            isHolderNameVisible: true,
            isSwipeGestureEnabled: false,
            height: kCardHeight,
            width: kCardWidth,
            cardBgColor: cardData[index].backgroundColor,
            onCreditCardWidgetChange: (_) {},
          ),
        ),
      ),
    );
  }

  double _getCardTopPosition(int index, bool isSelected) {
    if (isSelected) return kSpaceBetweenCard;
    
    if (selectedCardIndex != null && index > selectedCardIndex!) {
      return kSpaceUnselectedCardToTop + (index - 1) * kSpaceBetweenUnselectCard;
    }
    return kSpaceUnselectedCardToTop + index * kSpaceBetweenUnselectCard;
  }

  double _getCardScale(int index, bool isSelected) {
    if (isSelected) return 1.0;
    return 1.0 - (cardData.length - index - 1) * 0.05;
  }

  double _calculateTotalHeight() {
    if (selectedCardIndex == null) {
      return (kCardHeight + kSpaceBetweenCard) * cardData.length;
    }
    return kSpaceUnselectedCardToTop + kCardHeight + (cardData.length - 1) * kSpaceBetweenUnselectCard;
  }

  void _unselectCard() => setState(() => selectedCardIndex = null);
}