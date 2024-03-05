import json
import traceback
from urllib import request
from pyrogram import Client
from pyrogram.types.bots_and_keyboards.inline_keyboard_button import InlineKeyboardButton
from pyrogram.types.bots_and_keyboards.inline_keyboard_markup import InlineKeyboardMarkup
import logging
import sys
import os
import requests
import time
from ftplib import FTP_TLS, FTP
from pyrogram import enums

API_ID = '19769699'  # my.telegram.org
API_HASH = '628da4aad23822f35760c68df1bbf238'  # my.telegram.org
TOKEN = '1752717554:AAE5J6oKDZrsPNl1JcC7dUfAj2ZYsxhXJ84'  # @botfather
GP_ID = ''  # group id or public username
MGR_ID = ''  # manage id
# ftp section
FTP_USER = 'fileech@dl.fileechbot.ir'
FTP_PASS = 'Gv71&5bORtdm'
FTP_SERV = '94.130.135.171'
# endpoints
ORDER_INFO = 'https://fileechbot.ir/fileech_prime/api/get_file_info.php'
ORDER_SUBMIT = 'http://fileechbot.ir/fileech_prime/api/submit_status.php'
HOST_FOLDER = 'https://dl.fileechbot.ir/dl.fileechbot.ir/fileech/'

logging.basicConfig(level=logging.WARNING)
app = Client('upbot', api_id=API_ID, api_hash=API_HASH, bot_token=TOKEN)

async def get_entity_id(chat):
    try:
        entity = await client.get_entity(chat)
        print("Entity ID:", entity.id)
    except Exception as e:
        print("Error:", e)
        
def format_file_size(size_in_bytes):
    units = ['B', 'KB', 'MB', 'GB']
    base = 1024
    unit_index = 0

    while size_in_bytes > base and unit_index < len(units) - 1:
        size_in_bytes /= base
        unit_index += 1

    return f"{round(size_in_bytes, 2)} {units[unit_index]}"

def send_message(chat_id, msg_id, text, reply_markup, parse_mode):
    app.send_message(
        chat_id=int(chat_id),
        reply_to_message_id=int(msg_id),
        text=text,
        reply_markup=reply_markup,
        disable_web_page_preview=True,
        parse_mode=parse_mode
    )

def forward_message(chat_id, from_chat_id, message_id):
    app.forward_messages(
        chat_id=int(chat_id),
        from_chat_id=from_chat_id,
        message_ids=int(message_id)
    )
    
def copyMessage(chat_id, from_chat_id, msg_id, message_id, caption):
    app.copy_message(
    chat_id=int(chat_id),
    from_chat_id=from_chat_id,
    reply_to_message_id=msg_id,
    message_ids=message_id,
    caption=caption
    )    
    

def send_file(file_type, file_id, chat_id):
    if file_type == 'audio':
        return app.send_audio(
            chat_id=int(chat_id),
            audio=file_id
        )
    elif file_type == 'photo':
        return app.send_photo(
            chat_id=int(chat_id),
            photo=file_id
        )
    elif file_type == 'video':
        return app.send_video(
            chat_id=int(chat_id),
            video=file_id
        )

def edit_message_caption(chat_id, msg_id, text, parse_mode):
    app.edit_message_caption(
        chat_id=int(chat_id),
        message_id=int(msg_id),
        caption=text + f'\n{time.time()}',
        parse_mode=parse_mode,
        reply_markup=None
    )

def edit_message_text(chat_id, msg_id, text, parse_mode):
    app.edit_message_text(
        chat_id=int(chat_id),
        message_id=int(msg_id),
        text=text + f'\n{time.time()}',
        parse_mode=parse_mode
    )

def upload_file(file_path, user, passw, server):
    with FTP_TLS(server, user, passw) as ftp, open(file_path, 'rb') as file:
        ftp.storbinary(f'STOR {file_path}', file)

def download_file(file_url, file_path, open_order, order_id, get_order_info, chat_id, message_id):
    opener = request.build_opener()
    opener.addheaders = [('User-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36')]
    request.install_opener(opener)

    response = request.urlopen(file_url)
    chunk_size = 8192
    bytes_written = 0
    last_update_time = time.time()
    prograss_string = '▢' * 10
    message = f'''
📍سفارش های باز/تکمیل ({open_order} / 10)
💵هزینه سفارش: {format(int(get_order_info["price"]), ",")} تومان
📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}

⚙️وضعیت: در حال دانلود فایل ..‌
📥[{prograss_string}]
{time.time()}
👨🏻‍💻پشتیبانی: @FileechAdmin

☘️در جشنواره بهار فایلیچ با 20% تخفیف اشتراک فایلیچ پرایم رو خریداری یا تمدید کنید!

🟢اطلاعات بیشتر:
➡️ t.me/Fileech/256
'''
    try:
        edit_message_caption(chat_id, message_id, message, enums.ParseMode.HTML)
    except:
        pass
    
    with open(file_path, 'wb') as file:
        while True:
            data = response.read(chunk_size)
            if not data:
                break

            file.write(data)
            bytes_written += len(data)

            # امکان تعیین درصد پیشرفت وجود ندارد، بنابراین تنها تعداد بایت‌های دریافت شده را نمایش می‌دهیم.
            # هر 5 ثانیه وضعیت را به‌روزرسانی می‌کنیم.
            current_time = time.time()
            time_diff = current_time - last_update_time

            if time_diff >= 5:
                message = f'''
📍سفارش های باز/تکمیل ({open_order} / 10)
💵هزینه سفارش: {format(int(get_order_info["price"]), ",")} تومان
📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}

⚙️وضعیت: در حال دانلود فایل ..‌
📥 {format_file_size(bytes_written)} 
{time.time()}
👨🏻‍💻پشتیبانی: @FileechAdmin

☘️در جشنواره بهار فایلیچ با 20% تخفیف اشتراک فایلیچ پرایم رو خریداری یا تمدید کنید!

🟢اطلاعات بیشتر:
➡️ t.me/Fileech/256
'''
                try:
                    edit_message_caption(chat_id, message_id, message, enums.ParseMode.HTML)
                except:
                    pass
                last_update_time = time.time()


def upload_file_with_progress(file_path, chat_id, open_order, order_id, get_order_info, message_id):
    progress = 0
    last_update_time = time.time()
    file_size = os.path.getsize(file_path)
    
    def progress_callback(current, total):
        nonlocal progress, last_update_time, file_size, message_last_send, file_id
        progress = (current / total) * 100
        progress_percent = min(100, round(progress))
        prograss_bar = round(progress / 10)
        prograss_string = '▣' * prograss_bar + '▢' * (10 - prograss_bar)
        current_time = time.time()
        time_diff = current_time - last_update_time

        if time_diff >= 5:
            #print(f'upload to telegram : {progress}')
            message = f'''
📍سفارش های باز/تکمیل ({open_order} / 10) 
💵هزینه سفارش: {format(int(get_order_info["price"]), ",")} تومان
📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}

⚙️وضعیت: در حال آپلود فایل به تلگرام ..‌
📤 [{prograss_string}] {progress_percent}% ({format_file_size(file_size)})
{current_time}
👨🏻‍💻پشتیبانی: @FileechAdmin

☘️در جشنواره بهار فایلیچ با 20% تخفیف اشتراک فایلیچ پرایم رو خریداری یا تمدید کنید!

🟢اطلاعات بیشتر:
➡️ t.me/Fileech/256
'''         
            try:
                edit_message_caption(chat_id, message_id, message, enums.ParseMode.HTML)
            except:
                pass
            
            last_update_time = time.time()

            
    if file_size > 2147483648:
        # File size is greater than 2GB so we will upload it to our FTP server and pass the link
        file_size = os.path.getsize(file_path)
        global block
        block = 0
        
        def ftp_progress(current):
            total = file_size
            progress = (block / total) * 100
            progress_percent = min(100, round(progress))
            prograss_bar = round(progress / 10)
            prograss_string = '▣' * prograss_bar + '▢' * (10 - prograss_bar)

            message = f'''
📍سفارش های باز/تکمیل ({open_order} / 10) 
💵هزینه سفارش: {format(int(get_order_info["price"]), ",")} تومان
📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}

⚙️وضعیت: در حال آپلود فایل به هاست دانلود ..‌
📤 [{prograss_string}] {progress_percent}% ({format_file_size(file_size)})

👨🏻‍💻پشتیبانی: @FileechAdmin

☘️در جشنواره بهار فایلیچ با 20% تخفیف اشتراک فایلیچ پرایم رو خریداری یا تمدید کنید!

🟢اطلاعات بیشتر:
➡️ t.me/Fileech/256
'''         
            try:
                edit_message_caption(chat_id, message_id, message, enums.ParseMode.HTML)
            except:
                pass
            
        
        with FTP(FTP_SERV, FTP_USER, FTP_PASS, timeout=300) as ftp, open(file_path, 'rb') as file:
            ftp.storbinary(f'STOR {get_order_info["file_name"]}', file, blocksize=1048576, callback=ftp_progress)
            
        
        download_url = requests.get(f'http://dl.fileechbot.ir/download/create.php?file={get_order_info["file_name"]}').text
        message = f'''
📤 به علت محدودیت آپلود ۲ گیگابایت تلگرام،‌ فایل شما در هاست دانلود آپلود شده و آماده است.

📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}
📝 نام فایل :‌ {get_order_info["file_name"]}
🔗 لینک دانلود‌ : {download_url}

👨🏻‍💻پشتیبانی: @FileechAdmin
'''
        app.send_message(
            chat_id,
            message,
            reply_to_message_id=message_id
        )
        
        ftp.close()
        
    else:
        file = app.send_document(
            chat_id=int(chat_id),
            document=file_path,
            file_name=get_order_info['file_name'],
            reply_markup=InlineKeyboardMarkup([[InlineKeyboardButton(text='دریافت لینک دانلود', callback_data=f'Directlink_{get_order_info["id"]}')]]),
            reply_to_message_id=int(message_id),
            progress=progress_callback
        )
        message_last_send = file.id
        file_id = file.document.file_id
        send_archive = send_file(
                        get_order_info['archive']['preview']['type'],
                        get_order_info['archive']['preview']['file_id'],
                        get_order_info['archive']['chat_id']
                    )
        url = f"https://api.telegram.org/bot{TOKEN}/copyMessage?from_chat_id={chat_id}&message_id={message_last_send}&chat_id={get_order_info['archive']['chat_id']}&reply_to_message_id={send_archive.id}&caption={get_order_info['link']}"
        print(url)
        requests.get(url)
        return file_id
    
def main():
    order_id = int(sys.argv[1])
    if not isinstance(order_id, int) or order_id < 1:
        print('Enter order id')
        return

    try:
        print(f'{order_id}')
        get_order_info = json.loads(requests.get(f'{ORDER_INFO}?id={order_id}').text)
        if not get_order_info.get('ok', False):
            print(f"error step -1: {get_order_info.get('msg')}\norder id: {order_id}")
            return
    except Exception as e:
        print(f'error step -11: {e}\norder id: {order_id}')
        return

    file_url = get_order_info['download_link']
    file_name = get_order_info['file_name']
    file_path = f'{file_name}'
    chat_id = get_order_info['group']['chat_id']
    rply_message_id = get_order_info['group']['message_id']
    open_order = get_order_info['group']['open_order']
    message_id = rply_message_id
    message_id = rply_message_id
    last_update_time = time.time()
    file_id = None
    message_last_send = 0

    
    with app:
        message = f'''
📍سفارش های باز/تکمیل ({open_order} / 10) 
💵هزینه سفارش: {format(int(get_order_info["price"]), ",")} تومان
📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}

⚙️وضعیت: در حال پردازش اطلاعات ...
{last_update_time}
👨🏻‍💻پشتیبانی: @FileechAdmin

☘️در جشنواره بهار فایلیچ با 20% تخفیف اشتراک فایلیچ پرایم رو خریداری یا تمدید کنید!

🟢اطلاعات بیشتر:
➡️ t.me/Fileech/256
'''
        edit_message_caption(chat_id, rply_message_id, message, enums.ParseMode.HTML)
        

        try:
            print("start download")
            download_file(file_url, file_path, open_order, order_id, get_order_info, chat_id, message_id)
        except Exception as e:
            print(e)
            current_time = time.time()
            edit_message_text(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                f'failed upload link 2\norder id: {order_id}\nlink download: {file_url}\n{e}\n{current_time}',
                enums.ParseMode.HTML
            )
            send_message(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                f'Failed @FileechAdmin\n{e}',
                None,
                enums.ParseMode.HTML
            )
            return
            
        try:
            print("start upload")
            file_id = upload_file_with_progress(file_path, chat_id, open_order, order_id, get_order_info, message_id)
        except Exception as e:
            #print(f'failed upload file\norder id: {order_id}\nlink download: {file_url}\n{e}')
            print(e)
            current_time = time.time()
            edit_message_text(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                f'failed upload link 3\norder id: {order_id}\nlink download: {file_url}\n{e}\n{current_time}',
                enums.ParseMode.HTML
            )
            send_message(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                f'Failed @FileechAdmin\n{traceback.format_exc()}',
                None,
                enums.ParseMode.HTML
            )
            return

        try:
            os.remove(file_path)
            submit = json.loads(requests.get(f'{ORDER_SUBMIT}?id={order_id}&status=success&type=file&file_id={file_id}').text)

            if submit.get('ok', False):
                message = f'''
📍سفارش های باز/تکمیل ({open_order} / 10) 
💵هزینه سفارش: {format(int(get_order_info["price"]), ",")} تومان
📁کد فایل: {get_order_info["file_code"]}
#️⃣کد پیگیری: {order_id}

⚙️وضعیت: سفارش ارسال شد

👨🏻‍💻پشتیبانی: @FileechAdmin

☘️در جشنواره بهار فایلیچ با 20% تخفیف اشتراک فایلیچ پرایم رو خریداری یا تمدید کنید!

🟢اطلاعات بیشتر:
➡️ t.me/Fileech/256
'''
                try:
                    edit_message_caption(chat_id, message_id, message, enums.ParseMode.HTML)
                except:
                    pass
        except Exception as e:
            #print(f'failed upload file\norder id: {order_id}\nlink download: {file_url}\n{e}')
            current_time = time.time()
            edit_message_text(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                f'failed upload file 4\norder id: {order_id}\nlink download: {file_url}\n{e}\n{current_time}',
                enums.ParseMode.HTML
            )
            send_message(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                'Failed @FileechAdmin',
                None,
                enums.ParseMode.HTML
            )
            return
        
        try:
            edit_message_text(
                    get_order_info['manage']['chat_id'],
                    get_order_info['manage']['message_id'],
                    f'Done\ndate: {int(time.time())}\nfile_id: {file_id}\nname: {file_name}',
                    enums.ParseMode.HTML
                )
        except Exception as e:
            #print(f'failed upload file\norder id: {order_id}\nlink download: {file_url}\n{e}')
            edit_message_text(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                f'failed upload file 3\norder id: {order_id}\nlink download: {file_url}\n{e}',
                enums.ParseMode.HTML
            )
            send_message(
                get_order_info['manage']['chat_id'],
                get_order_info['manage']['message_id'],
                'Failed @FileechAdmin',
                None,
                enums.ParseMode.HTML

            )
            return
        

if __name__ == '__main__':
    main()

