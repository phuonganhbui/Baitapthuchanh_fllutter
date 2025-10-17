<?php

// namespace App\Http\Controllers\Api;

// use App\Http\Controllers\Controller;
// use App\Models\Category;
// use Illuminate\Http\Request;

// class CategoryController extends Controller
// {
//     /**
//      * Display a listing of the resource.
//      */
//     public function index()
//     {
//         return Category::all();
//     }

//     /**
//      * Store a newly created resource in storage.
//      */
//     public function store(Request $request)
//     {
//         $request->validate([
//             'name' => 'required|string|max:255|unique:categories,name',
//         ]);

//         $category = Category::create($request->all());
//         return response()->json($category, 201);
//     }

//     /**
//      * Display the specified resource.
//      */
//     public function show(Category $category)
//     {
//         return $category;
//     }

//     /**
//      * Update the specified resource in storage.
//      */
//     public function update(Request $request, Category $category)
//     {
//         $request->validate([
//             'name' => 'sometimes|required|string|max:255|unique:categories,name,' . $category->id,
//         ]);

//         $category->update($request->only('name'));
//         return $category->fresh();
//     }

//     /**
//      * Remove the specified resource from storage.
//      */
//     public function destroy(Category $category)
//     {
//         $category->delete();
//         return response()->json(null, 204);
//     }
// }



namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Cache::remember('categories_list', 60, function () {
            return Category::with('products')->get();
        });

        return response()->json($categories);
    }

    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255|unique:categories,name',
            ], [
                'name.required' => 'Tên danh mục là bắt buộc.',
                'name.unique' => 'Tên danh mục đã tồn tại.',
            ]);

            $category = Category::create($request->all());

            // Xóa cache khi tạo danh mục mới
            Cache::forget('categories_list');
            Cache::forget('products_list'); // Vì products có thể liên quan đến category

            return response()->json($category, 201);
        } catch (ValidationException $ve) {
            throw $ve;
        } catch (\Throwable $e) {
            throw $e;
        }
    }

    public function show(Category $category)
    {
        return response()->json($category->load('products'));
    }

    public function update(Request $request, Category $category)
    {
        try {
            $request->validate([
                'name' => 'sometimes|required|string|max:255|unique:categories,name,' . $category->id,
            ], [
                'name.required' => 'Tên danh mục là bắt buộc.',
                'name.unique' => 'Tên danh mục đã tồn tại.',
            ]);

            $category->update($request->only('name'));

            // Xóa cache khi cập nhật danh mục
            Cache::forget('categories_list');
            Cache::forget('products_list');

            return response()->json($category);
        } catch (ValidationException $ve) {
            throw $ve;
        } catch (\Throwable $e) {
            throw $e;
        }
    }

    public function destroy(Category $category)
    {
        $category->delete();

        // Xóa cache khi xóa danh mục
        Cache::forget('categories_list');
        Cache::forget('products_list');

        return response()->json(null, 204);
    }
}
