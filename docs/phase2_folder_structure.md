# BaoBab HR — Phase 2 Folder Structure

```text
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── profile_provider.dart
│   │   └── theme_provider.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   └── services/
│       ├── auth_service.dart
│       ├── employee_service.dart
│       ├── storage_service.dart
│       └── supabase_service.dart
├── models/
│   └── employee_model.dart
├── views/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── employee_login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── verify_email_screen.dart
│   │   └── unauthorized_screen.dart
│   ├── dashboard/
│   │   ├── super_dashboard.dart
│   │   ├── hr_dashboard.dart
│   │   └── employee_dashboard.dart
│   └── ... (existing feature screens)
└── main.dart
```

## Routing map
- `super_admin` → `/super-dashboard`
- `hr_admin` → `/hr-dashboard`
- `employee` → `/employee-dashboard`

## Public routes
- `/login`
- `/employee-login`
- `/forgot-password`
- `/verify-email`
- `/unauthorized`
