import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'movie_data.dart';

class MovieCard extends InkWell {
  MovieCard({
    super.key,
    required Movie movie,
    required VoidCallback onTap,
    double radius = 16,
  }) : super(
         onTap: onTap,
         child: Semantics(
           label: movie.title,
           child: Container(
             alignment: Alignment.topLeft,
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(radius),
               image: DecorationImage(
                 image: NetworkImage(movie.poster),
                 fit: BoxFit.cover,
               ),
             ),
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
               decoration: BoxDecoration(
                 color: const Color(0xB5121312),
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     movie.rating,
                     style: const TextStyle(color: Colors.white),
                   ),
                   const SizedBox(width: 4),
                   const Icon(Icons.star, size: 16, color: AppTheme.yellow),
                 ],
               ),
             ),
           ),
         ),
       );
}
