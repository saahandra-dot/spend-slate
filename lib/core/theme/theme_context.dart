import 'package:flutter/material.dart';

extension AppThemeContext on BuildContext {
  Color get appBackground {
    return Theme.of(this).scaffoldBackgroundColor;
  }

  Color get appSurface {
    return Theme.of(this).colorScheme.surface;
  }

  Color get appTextPrimary {
    return Theme.of(this).colorScheme.onSurface;
  }

  Color get appTextSecondary {
    return Theme.of(this).colorScheme.onSurfaceVariant;
  }

  Color get appTextLight {
    return Theme.of(this).colorScheme.onSurfaceVariant.withValues(alpha: 0.68);
  }

  Color get appDivider {
    return Theme.of(this).dividerColor;
  }

  Color get appSoftPrimary {
    return Theme.of(this).colorScheme.primaryContainer;
  }
}
