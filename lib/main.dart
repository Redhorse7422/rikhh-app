import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/products/bloc/products_bloc.dart';
import 'features/products/bloc/categories_bloc.dart';
import 'features/products/repositories/products_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/home/bloc/location_bloc.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoriesBloc>(
          create: (context) =>
              CategoriesBloc(productsRepository: ProductsRepositoryImpl()),
        ),
        BlocProvider<ProductsBloc>(
          create: (context) =>
              ProductsBloc(productsRepository: ProductsRepositoryImpl()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repo: AuthRepository()),
        ),
        BlocProvider<LocationBloc>(create: (context) => LocationBloc()),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
