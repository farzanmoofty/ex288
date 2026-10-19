#!/usr/bin/env python3
import os
import subprocess
from datetime import datetime

def send_mail():
    """Send email notification after build completes"""
    build_name = os.environ.get('OPENSHIFT_BUILD_NAME', 'unknown-build')
    build_namespace = os.environ.get('OPENSHIFT_BUILD_NAMESPACE', 'unknown-namespace')
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    subject = f"Build {build_name} completed"
    body = f"""
Build Notification
==================
Build Name: {build_name}
Namespace: {build_namespace}
Timestamp: {timestamp}
Status: SUCCESS

This email was sent automatically by the post-commit build hook.
"""
    
    # Send email using mail command
    try:
        # Write message to file
        with open('/tmp/mail_message.txt', 'w') as f:
            f.write(body)
        
        # Send mail
        mail_cmd = f'mail -s "{subject}" capnhook < /tmp/mail_message.txt'
        result = subprocess.run(mail_cmd, shell=True, capture_output=True, text=True)
        
        print(f"Email sent to capnhook user")
        print(f"Subject: {subject}")
        print(f"Return code: {result.returncode}")
        
        if result.returncode != 0:
            print(f"Warning: mail command returned non-zero exit code")
            print(f"Stderr: {result.stderr}")
    except Exception as e:
        print(f"Error sending email: {e}")

if __name__ == '__main__':
    send_mail()
    print("mailer.py script executed successfully")
