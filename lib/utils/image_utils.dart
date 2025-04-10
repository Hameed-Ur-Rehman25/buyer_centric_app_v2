import 'package:flutter/material.dart';

/// Utility class to handle image loading with proper error handling
class ImageUtils {
  /// Validates if the URL is properly formatted
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Load a network image with proper error handling
  static Widget loadNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? backgroundColor,
    Widget? errorWidget,
    Widget? loadingWidget,
  }) {
    // Validate URL first
    if (!isValidImageUrl(imageUrl)) {
      return _buildErrorWidget(errorWidget, width, height, backgroundColor);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return loadingWidget ?? _buildDefaultLoadingWidget(
          context,
          loadingProgress,
          width,
          height,
          backgroundColor,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(errorWidget, width, height, backgroundColor);
      },
    );
  }

  /// Default loading widget with progress indicator
  static Widget _buildDefaultLoadingWidget(
    BuildContext context,
    ImageChunkEvent loadingProgress,
    double? width,
    double? height,
    Color? backgroundColor,
  ) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading image...',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            if (loadingProgress.expectedTotalBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${((loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Default error widget when image fails to load
  static Widget _buildErrorWidget(
    Widget? customErrorWidget,
    double? width,
    double? height,
    Color? backgroundColor,
  ) {
    if (customErrorWidget != null) return customErrorWidget;
    
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Load a local asset image with proper error handling
  static Widget loadAssetImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? backgroundColor,
    Widget? errorWidget,
  }) {
    // Clean up the path for asset loading
    String fixedPath = _cleanAssetPath(imagePath);
    
    // Use asset image with error handling
    return Image.asset(
      fixedPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(errorWidget, width, height, backgroundColor);
      },
    );
  }
  
  /// Clean up an asset path for proper loading
  static String _cleanAssetPath(String path) {
    String result = path;
    
    // Handle file:// protocol
    if (result.startsWith('file:///')) {
      result = result.replaceAll('file:///', '');
    }
    
    // Ensure path starts with 'assets/'
    if (!result.startsWith('assets/')) {
      result = 'assets/$result';
    }
    
    // Remove any duplicate 'assets/' prefixes
    while (result.contains('assets/assets/')) {
      result = result.replaceAll('assets/assets/', 'assets/');
    }
    
    return result;
  }
} 