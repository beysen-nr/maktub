@override
Widget build(BuildContext context) {
  return BlocBuilder<CartBloc, CartState>(
    builder: (context, cartState) {
      int quantity = 0;
      String? cartItemId;

      if (cartState is CartLoaded) {
        final match = cartState.items.firstWhere(
          (e) => e.item.productId == product.id,
          orElse: () => ValidatedCartItem(
            item: CartItem(
              cartItemId: '',
              productId: -1,
              supplierProductId: '',
              supplierId: '',
              quantity: 0,
              price: 0,
              totalPrice: 0,
            ),
            isInStock: true,
          ),
        );

        if (match.item.productId != -1) {
          quantity = match.item.quantity;
          cartItemId = match.item.cartItemId;
        }
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: FadeInNetworkImage(
                imageUrl: product.imageUrl.first,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(
                product.productNameKz.toLowerCase(),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.price * product.quantity}₸ за ${product.quantity} шт',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Gradients.detailTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Цена: ',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Gradients.detailTextColor,
                        ),
                      ),
                      Text(
                        product.supplierName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Gradients.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  quantity == 0
                      ? ElevatedButton(
                          onPressed: () {
                            context.read<CartBloc>().add(
                                  AddCartItem(
                                    item: CartItem(
                                      cartItemId: '',
                                      productId: product.id,
                                      supplierProductId: product.supplierProductId,
                                      supplierId: product.supplierId,
                                      quantity: 1,
                                      price: product.price,
                                      totalPrice: product.price,
                                    ),
                                    organizationId: product.organizationId,
                                  ),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Gradients.primary,
                            minimumSize: const Size.fromHeight(45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Қосу'),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    context.read<CartBloc>().add(
                                          UpdateCartItemQuantity(
                                            cartItemId: cartItemId!,
                                            newQuantity: quantity - 1,
                                            organizationId: product.organizationId,
                                          ),
                                        );
                                  } else {
                                    context.read<CartBloc>().add(
                                          RemoveCartItem(
                                            cartItemId: cartItemId!,
                                            organizationId: product.organizationId,
                                          ),
                                        );
                                  }
                                },
                                icon: const Icon(Icons.remove, color: Gradients.primary),
                              ),
                              Text(
                                '$quantity',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        UpdateCartItemQuantity(
                                          cartItemId: cartItemId!,
                                          newQuantity: quantity + 1,
                                          organizationId: product.organizationId,
                                        ),
                                      );
                                },
                                icon: const Icon(Icons.add, color: Gradients.primary),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
