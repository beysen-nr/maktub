import 'package:maktub/data/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final _client = Supabase.instance.client;

Future<List<Category>> fetchAllCategories() async {
  final List data = await _client.from('category').select();

  return data.map((e) => Category.fromMap(e as Map<String, dynamic>)).toList();
}



}
