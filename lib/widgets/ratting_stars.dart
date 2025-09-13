import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final String ratting;

  const RatingStars({super.key, required this.ratting});

  @override
  Widget build(BuildContext context) {
    // Convert the 'ratting' string to a double, then to integer for star display
    double ratingDouble = double.tryParse(ratting) ?? 0.0;
    int ratingValue = ratingDouble.round();

    // Ensure the rating is between 0 and 5
    if (ratingValue > 5) ratingValue = 5;
    if (ratingValue < 0) ratingValue = 0;

    return Row(
      children: <Widget>[
        // Display the filled yellow stars based on the rating value
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= ratingValue ? Icons.star : Icons.star_border, // Filled or empty star
            color: i <= ratingValue ? Colors.amber : Colors.grey, // Yellow for filled stars
            size: 20, // Adjust size as per your requirement
          ),
        // Display the rating text next to stars
      ],
    );
  }
}
