# استخدام صورة Xray من teddysun (تدعم VLESS)
FROM teddysun/xray:latest

# فتح المنفذ 8080 (مطلوب لـ Cloud Run)
EXPOSE 8080

# نسخ ملف التكوين إلى داخل الحاوية
COPY config.json /etc/v2ray/config.json

# تشغيل خدمة Xray مع ملف التكوين
CMD ["xray", "run", "-config", "/etc/v2ray/config.json"]
