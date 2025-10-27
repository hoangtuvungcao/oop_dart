import os

def rename_images(folder_path):
    # Lấy danh sách file trong thư mục
    files = os.listdir(folder_path)
    
    # Lọc chỉ lấy file ảnh (đuôi jpg, png, jpeg...)
    image_files = [f for f in files if f.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'))]
    
    # Sort danh sách ảnh cho gọn gàng
    image_files.sort()
    
    # Đổi tên từ 1.png → n.png
    for i, filename in enumerate(image_files, start=1):
        # Giới hạn 100 file
        if i > 100:
            break
        
        # Lấy đuôi file gốc (giữ định dạng gốc)
        ext = os.path.splitext(filename)[1].lower()
        
        new_name = f"{i}{ext}"   # ví dụ: 1.png, 2.png
        old_path = os.path.join(folder_path, filename)
        new_path = os.path.join(folder_path, new_name)

        os.rename(old_path, new_path)
        print(f"Renamed: {filename} -> {new_name}")

# Ví dụ chạy
folder = r"C:\Users\Admin\Downloads\png"  # đổi path này thành folder của bạn
rename_images(folder)
