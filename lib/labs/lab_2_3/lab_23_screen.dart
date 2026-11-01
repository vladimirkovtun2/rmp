import 'package:flutter/material.dart';

/// Лабораторная работа №2.3 — адаптеры: список товаров с корзиной.
///
/// «Адаптер» по методичке — это метод buildProductItem + ListView.builder:
/// данные (список Product) преобразуются в элементы интерфейса.
/// По п. 4 задания каталог изменён: другие товары, цены и остатки.
class Lab23Screen extends StatefulWidget {
  const Lab23Screen({super.key});

  @override
  State<Lab23Screen> createState() => _Lab23ScreenState();
}

// Модель товара
class Product {
  final String name;
  final double price;
  final IconData icon;
  // Доступное количество товаров в магазине
  int availableQuantity;
  int cartQuantity; // Количество товара в корзине

  Product({
    required this.name,
    required this.price,
    required this.icon,
    this.availableQuantity = 10,
    this.cartQuantity = 0,
  });
}

class _Lab23ScreenState extends State<Lab23Screen> {
  // Каталог (изменён в рамках задания: товары, цены, остатки — на выбор)
  List<Product> products = [
    Product(
      name: 'Пицца «Маргарита»',
      price: 890.0,
      icon: Icons.local_pizza,
      availableQuantity: 8,
    ),
    Product(
      name: 'Кофе американо',
      price: 350.0,
      icon: Icons.local_cafe,
      availableQuantity: 15,
    ),
    Product(
      name: 'Мороженое',
      price: 420.0,
      icon: Icons.icecream,
      availableQuantity: 5,
    ),
    Product(
      name: 'Бургер',
      price: 640.0,
      icon: Icons.lunch_dining,
      availableQuantity: 10,
    ),
    Product(
      name: 'Лимонад',
      price: 280.0,
      icon: Icons.local_drink,
      availableQuantity: 20,
    ),
    Product(
      name: 'Суши-сет',
      price: 1150.0,
      icon: Icons.set_meal,
      availableQuantity: 4,
    ),
    Product(
      name: 'Чизкейк',
      price: 540.0,
      icon: Icons.cake,
      availableQuantity: 6,
    ),
  ];

  // Метод увеличения количества товара в корзине
  void incrementCartQuantity(Product product) {
    setState(() {
      if (product.availableQuantity > 0) {
        product.cartQuantity += 1;
        product.availableQuantity -= 1;
      }
    });
  }

  // Метод уменьшения количества товара в корзине
  void decrementCartQuantity(Product product) {
    setState(() {
      if (product.cartQuantity > 0) {
        product.cartQuantity -= 1;
        product.availableQuantity += 1;
      }
    });
  }

  // Подсчёт общего количества товаров в корзине
  int getTotalCartItems() {
    var totalItems = 0;
    for (var product in products) {
      totalItems += product.cartQuantity;
    }
    return totalItems;
  }

  // Подсчёт общей стоимости товаров в корзине
  double getTotalCartPrice() {
    var totalPrice = 0.0;
    for (var product in products) {
      totalPrice += product.price * product.cartQuantity;
    }
    return totalPrice;
  }

  // Отдельный метод для создания элемента списка товара («адаптер»)
  Widget buildProductItem(Product product) {
    return ListTile(
      leading:
          // Иконка товара
          Icon(product.icon, size: 40, color: Colors.blue),
      title: Text(product.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Цена: ${product.price.toStringAsFixed(2)} ₽'),
          Text('В наличии: ${product.availableQuantity}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка уменьшения количества товара в корзине
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => decrementCartQuantity(product),
          ),
          // Отображение количества товара в корзине
          Text(product.cartQuantity.toString()),
          // Кнопка увеличения количества товара в корзине
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => incrementCartQuantity(product),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Товары'),
        actions: [
          // Отображение количества товаров и общей суммы в корзине
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Сумма: ${getTotalCartPrice().toStringAsFixed(2)} ₽'),
                  Text('Товары: ${getTotalCartItems()}'),
                ],
              ),
            ),
          ),
          const Icon(Icons.shopping_cart),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return buildProductItem(product);
        },
      ),
    );
  }
}
