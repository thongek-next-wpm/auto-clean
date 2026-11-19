# Auto Clean (Windows Batch Script)

สคริปต์ `.bat` สำหรับทำความสะอาดไฟล์ขยะ (Temp, Cache, และ Recycle Bin) บน Windows อย่างปลอดภัย พร้อมแถบแสดงความคืบหน้า (Progress Bar) แบบเรียลไทม์

## คุณสมบัติ (Features)

1. **User Temporary Files (`%TEMP%`, `%TMP%`)**: ลบไฟล์ชั่วคราวของผู้ใช้ปัจจุบัน
2. **Windows System Temp Files (`C:\Windows\Temp`)**: ลบไฟล์ชั่วคราวของระบบ Windows
3. **Windows Caches & DNS Cache**:
   - ล้าง `INetCache\IE`, `CrashDumps`, `Windows Error Reporting (WER)` และ `thumbcache_*.db`
   - ล้าง DNS Cache (`ipconfig /flushdns`)
4. **Browser Caches (ลบเฉพาะ Cache โดยไม่กระทบ Cookies, History หรือรหัสผ่าน)**:
   - Google Chrome
   - Microsoft Edge
   - Brave Browser
   - Mozilla Firefox
5. **Empty Recycle Bin**: ล้างถังขยะทุกไดรฟ์อัตโนมัติ

## วิธีใช้งาน (Usage)

- ดับเบิลคลิกไฟล์ `auto_clean.bat` เพื่อรันได้ทันที
- **แนะนำ:** คลิกขวาแล้วเลือก **Run as administrator** เพื่อให้สคริปต์สามารถล้างไฟล์ใน `C:\Windows\Temp` ได้อย่างสมบูรณ์
