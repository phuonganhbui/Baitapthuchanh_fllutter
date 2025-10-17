<?php

// namespace App\Http\Controllers\Api;

// use App\Http\Controllers\Controller;
// use App\Models\Product;
// use Illuminate\Http\Request;
// use Illuminate\Support\Facades\Log;
// use Illuminate\Validation\ValidationException;

// class ProductController extends Controller
// {
//     public function index()
//     {
//         return Product::with('category')->get();
//     }

//     public function store(Request $request)
//     {

//         try {
//             $request->validate([
//                 'name' => 'required|string|max:255|unique:products,name',
//                 'description' => 'nullable|string|max:500',
//                 'price' => 'required|numeric|min:0',
//                 'category_id' => 'nullable|exists:categories,id',
//             ], [
//                 'name.required' => 'Tên sản phẩm là bắt buộc.',
//                 'name.unique' => 'Tên sản phẩm đã tồn tại.',
//                 'description.max' => 'Mô tả không được vượt quá 500 ký tự.',
//                 'price.min' => 'Giá phải lớn hơn hoặc bằng 0.',
//                 'category_id.exists' => 'Danh mục không hợp lệ.',
//             ]);
//             $product = Product::create($request->all());

//             return response()->json($product, 201);
//         } catch (ValidationException $ve) {

//             throw $ve; // để Laravel trả 422 chuẩn
//         } catch (\Throwable $e) {
//             throw $e; // 500 (hoặc tự return 500 JSON)
//         }
//     }


//     public function show(Product $product)
//     {
//         return $product->load('category');
//     }

//     public function update(Request $request, Product $product)
//     {
//         $request->validate([
//             'name' => 'sometimes|required|string|max:255|unique:products,name,' . $product->id,
//             'description' => 'nullable|string|max:500',
//             'price' => 'sometimes|required|numeric|min:0',
//             'category_id' => 'nullable|exists:categories,id',
//         ], [
//             'name.required' => 'Tên sản phẩm là bắt buộc.',
//             'name.unique' => 'Tên sản phẩm đã tồn tại.',
//             'description.max' => 'Mô tả không được vượt quá 500 ký tự.',
//             'price.min' => 'Giá phải lớn hơn hoặc bằng 0.',
//             'category_id.exists' => 'Danh mục không hợp lệ.',
//         ]);
//         $product->update($request->only('name', 'price', 'description', 'category_id'));
//         return $product->load('category');
//     }

//     public function destroy(Product $product)
//     {
//         $product->delete();
//         return response()->json(null, 204);
//     }
// }




namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;

class ProductController extends Controller
{
    public function index()
    {
        // Sử dụng cache để lưu trữ danh sách sản phẩm trong 60 giây
        $products = Cache::remember('products_list', 60, function () {
            return Product::with('category')->get();
        });

        return response()->json($products);
    }

    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255|unique:products,name',
                'description' => 'nullable|string|max:500',
                'price' => 'required|numeric|min:0',
                'category_id' => 'nullable|exists:categories,id',
            ], [
                'name.required' => 'Tên sản phẩm là bắt buộc.',
                'name.unique' => 'Tên sản phẩm đã tồn tại.',
                'description.max' => 'Mô tả không được vượt quá 500 ký tự.',
                'price.min' => 'Giá phải lớn hơn hoặc bằng 0.',
                'category_id.exists' => 'Danh mục không hợp lệ.',
            ]);

            $product = Product::create($request->all());

            // Xóa cache khi tạo sản phẩm mới
            Cache::forget('products_list');

            return response()->json($product->load('category'), 201);
        } catch (ValidationException $ve) {
            throw $ve;
        } catch (\Throwable $e) {
            throw $e;
        }
    }

    public function show(Product $product)
    {
        return response()->json($product->load('category'));
    }

    public function update(Request $request, Product $product)
    {
        try {
            $request->validate([
                'name' => 'sometimes|required|string|max:255|unique:products,name,' . $product->id,
                'description' => 'nullable|string|max:500',
                'price' => 'sometimes|required|numeric|min:0',
                'category_id' => 'nullable|exists:categories,id',
            ], [
                'name.required' => 'Tên sản phẩm là bắt buộc.',
                'name.unique' => 'Tên sản phẩm đã tồn tại.',
                'description.max' => 'Mô tả không được vượt quá 500 ký tự.',
                'price.min' => 'Giá phải lớn hơn hoặc bằng 0.',
                'category_id.exists' => 'Danh mục không hợp lệ.',
            ]);

            $product->update($request->only('name', 'price', 'description', 'category_id'));

            // Xóa cache khi cập nhật sản phẩm
            Cache::forget('products_list');

            return response()->json($product->load('category'));
        } catch (ValidationException $ve) {
            throw $ve;
        } catch (\Throwable $e) {
            throw $e;
        }
    }

    public function destroy(Product $product)
    {
        $product->delete();

        // Xóa cache khi xóa sản phẩm
        Cache::forget('products_list');

        return response()->json(null, 204);
    }
}
