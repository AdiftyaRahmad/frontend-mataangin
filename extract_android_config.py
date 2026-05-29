#!/usr/bin/env python3
"""
Script untuk extract API key dan App ID dari google-services.json
"""

import json
import os

def extract_android_config():
    # Path ke google-services.json
    json_path = os.path.join('android', 'app', 'google-services.json')
    
    if not os.path.exists(json_path):
        print("❌ File google-services.json tidak ditemukan!")
        print(f"   Path: {json_path}")
        print("\n📥 Download dulu dari Firebase Console:")
        print("   https://console.firebase.google.com/project/mata-angin-e1f8d/settings/general")
        return
    
    # Baca file
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # Extract data
    try:
        client = data['client'][0]
        api_key = client['api_key'][0]['current_key']
        app_id = client['client_info']['mobilesdk_app_id']
        package_name = client['client_info']['android_client_info']['package_name']
        project_id = data['project_info']['project_id']
        storage_bucket = data['project_info']['storage_bucket']
        messaging_sender_id = data['project_info']['project_number']
        
        print("=" * 60)
        print("📱 Android Firebase Configuration")
        print("=" * 60)
        print()
        print("✅ Berhasil extract config dari google-services.json!")
        print()
        print("📋 Copy kode ini ke firebase_options.dart:")
        print()
        print("static const FirebaseOptions android = FirebaseOptions(")
        print(f"  apiKey: '{api_key}',")
        print(f"  appId: '{app_id}',")
        print(f"  messagingSenderId: '{messaging_sender_id}',")
        print(f"  projectId: '{project_id}',")
        print(f"  storageBucket: '{storage_bucket}',")
        print(");")
        print()
        print("=" * 60)
        print("📦 Package Info:")
        print(f"   Package name: {package_name}")
        print("=" * 60)
        print()
        
        # Cek apakah API key masih yang lama (bocor)
        old_keys = [
            'AIzaSyBdyppWEtpdG_FyuSAnwcJbHj8clvJ3AVE',
            'AIzaSyB6wOuj1LaFwoW7WDnfqHuRUV6m6TSpx4M',
            'AIzaSyA8RIwN1LBnvsnGAXZ5Qcjo_M8Kb3c6by0'
        ]
        
        if api_key in old_keys:
            print("⚠️  WARNING: Ini masih API key LAMA yang bocor!")
            print("⚠️  Download google-services.json BARU dari Firebase Console!")
            print()
            print("📥 Cara download:")
            print("   1. Buka: https://console.firebase.google.com/project/mata-angin-e1f8d/settings/general")
            print("   2. Scroll ke 'Your apps' > Android app")
            print("   3. Klik icon ⚙️ > Download google-services.json")
            print("   4. Replace file di android/app/google-services.json")
            print("   5. Jalankan script ini lagi")
            print()
        else:
            print("✅ API key terlihat baru (bukan yang bocor)")
            print()
        
    except (KeyError, IndexError) as e:
        print(f"❌ Error parsing google-services.json: {e}")
        print("   File mungkin corrupt atau format tidak sesuai")

if __name__ == '__main__':
    extract_android_config()
