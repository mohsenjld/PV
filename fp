<?php

ini_set("log_errors", 1);
ini_set("error_log", $_SERVER["DOCUMENT_ROOT"] . "/fileech_prime/pv.log");


if (isset($update->message->photo) && $from_id == 1749600986) {
    $count = count($update->message->photo) - 1;
    $telegram->SendMessage(
        $from_id,
        "file_id : " . $update->message->photo[$count]->file_id,
        "HTML",
        true,
        null,
        true,
        null
    );
}

if (strpos($text, "ext") !== false) {
    $text = str_replace("ext", "", $text);

    $ext = explode("?", $text)[0]; // to get extension
    $ext = pathinfo($ext, PATHINFO_EXTENSION); // to get extension
    if ($ext == "") {
        $ext = explode("&", $text)[0]; // to get extension
        $telegram->SendMessage($chat_id, "ext : " . $ext, "HTML", true, null, true, null);
        $ext = pathinfo($ext, PATHINFO_EXTENSION); // to get extension
    }

    $telegram->SendMessage($chat_id, "ext : " . $ext, "HTML", true, null, true, null);
}

if (strpos($text, "start") !== false and strlen($text) > 6) {
    $start_data = explode(" ", $text);
    if (count($start_data) > 1) {
        if (strpos($start_data[1], "-") !== false) {
            $func->check_users($from_id, $first_name);
            $join_info = $func->sponsers($from_id, $text);
            $join_status = $join_info[0];
            if ($join_status == 1) {
                $join_btn = [
                    "inline_keyboard" =>
                        $join_info[1]
                ];
                $telegram->SendMessage(
                    $from_id,
                    $join_text,
                    "HTML",
                    true,
                    $join_btn,
                    true,
                    null
                );
                exit();
            }
            $data_for_send = explode("-", $start_data[1]);
            if ($data_for_send[0] == "pr") {
                $content_for_send = $func->get_table_row_info('filepacks', 'id', $data_for_send[1]);
                if (is_array($content_for_send)) {
                    $content_for_send = $content_for_send[0];
                    $downloaders = json_decode($content_for_send->downloaders);
                    if ($content_for_send->allow_download > count($downloaders) || in_array($from_id, $downloaders) || $func->check_user_has_prime($from_id)) {
                        if (!in_array($from_id, $downloaders) || !$func->check_user_has_prime($from_id)) {
                            array_push($downloaders, $from_id);
                            $func->update_table_row_info(
                                'filepacks',
                                'id',
                                $data_for_send[1],
                                'downloaders',
                                json_encode($downloaders));
                            $target_btn = [
                                "inline_keyboard" => [
                                    [
                                        ["text" => "🗳 " . count($downloaders) . " دانلود از " . $content_for_send->allow_download . " 🗳", "url" => "https://t.me/$bot_username?start=pr-" . $data_for_send[1]],

                                    ]
                                ]
                            ];

                            $b = $telegram->editMessageReplyMarkup(
                                "@FileechPacks",
                                $content_for_send->msgid,
                                $target_btn
                            );
                        }
                        $files_to_send = json_decode($content_for_send->file_id);
                        foreach ($files_to_send as $file_send) {

                            $telegram->Send_file(
                                $file_send[1],
                                $file_send[0],
                                $from_id,
                                null,
                                null,
                                null,
                                "HTML"
                            );

                        }
                    } else {
                        $telegram->SendMessage(
                            $from_id,
                            $limited_allow_download_text,
                            "HTML",
                            true,
                            $limited_allow_download_btn,
                            true,
                            null
                        );
                    }
                }
                exit();
            }
        } else {
            $inviter = $start_data[1];
            $func->check_users($from_id, $first_name, $inviter);
            if ($start_data[1] == "prime") {
                $text = "$start_btn_text_12";
            } elseif ($start_data[1] == "orderquantity") {
                $text = "$start_btn_text_14";
            } else {
                $text = "/start";
            }

        }
    }
} else {
    $func->check_users($from_id, $first_name);
}

$join_info = $func->sponsers($from_id);
$join_status = $join_info[0];
if ($join_status == 1) {
    $join_btn = [
        "inline_keyboard" =>
            $join_info[1]
    ];
    $telegram->SendMessage(
        $from_id,
        $join_text,
        "HTML",
        true,
        $join_btn,
        true,
        null
    );
    exit();
}

$info_user = $func->get_user($from_id);

if ($text == "بازگشت به منوی قبلی") {
    switch ($info_user->status) {
        case "free_order_menu":
        case "free_order":
            $telegram->SendMessage(
                $from_id,
                $start_btn_15_response_text,
                "HTML",
                true,
                $start_btn_15_response_keyboard,
                true,
                null
            );
            exit();
            break;
        case "buy_prime":
            $start_btn_12_response_keyboard = [
                "keyboard" =>

                    $func->get_primes('prime')
                ,
                "resize_keyboard" => true,
            ];
            $telegram->SendMessage(
                $from_id,
                $start_btn_12_response_text,
                "HTML",
                false,
                $start_btn_12_response_keyboard,
                false,
                false
            );
            exit();
            break;

        case "buy_prime2":
            $telegram->SendMessage(
                $from_id,
                $start_btn_18_response_text,
                "HTML",
                false,
                $start_btn_18_response_keyboard,
                false,
                false
            );

            exit();
            break;
        case "ordercount":
            $start_btn_14_response_inlineKeyboard = ["keyboard" => $func->count_order_sites(),
                "resize_keyboard" => true];

            $telegram->SendMessage(
                $from_id,
                $start_btn_14_response_text,
                "HTML",
                true,
                $start_btn_14_response_inlineKeyboard,
                true,
                null
            );

            $func->update_user($from_id, "status", "start_ordercount");

            break;

    }
}
switch ($text) {
    case $start_btn_text_15:
        $func->update_user($from_id, "status", "start");
        $telegram->SendMessage(
            $from_id,
            $start_btn_15_response_text,
            "HTML",
            true,
            $start_btn_15_response_keyboard,
            true,
            null
        );
        exit();

        break;
    case $start_btn_text_17:
        $telegram->SendMessage(
            $from_id,
            $response_start_btn_text_17,
            "HTML",
            true,
            $start_btn_17_inlineKeyboard,
            true,
            null
        );
        exit();
        break;
    case $btn_pay_buy_prime_btn_1:
        $price = 0;
        $type_subscription = "";
        $plan = $info_user->extra_info;
        $prime = $func->get_primes_by_id($plan);
        if ($prime == false) {
            echo json_encode(['ok' => false, "message" => "invalid plan"]);
            exit();
        }
        $type_subscription = $prime->short_name;
        $price = $prime->price * 10;

        if ($info_user->wallet >= ($price / 10)) {
            $order_id = $func->make_orderid();
            while ($order_id < 1) {
                $order_id = $func->make_orderid();
            }
            $func->add_payment_order($from_id, $order_id, "prime_$plan", $price, "0", "خرید اشتراک $type_subscription", json_encode([]));
            if ((int)$info_user->inviter > 1 && (int)$info_user->gift == 0) {
                if ($func->check_user_has_prime($info_user->inviter)) {
                    $func->update_user($from_id, 'gift', 1);
                    $func->charge_user($from_id, 40000, "+");
                    $func->charge_user($info_user->inviter, 80000, "+");

                    $telegram->SendMessage(
                        $info_user->inviter,
                        "مبلغ 80,000 تومان بابت معرفی دوستانتان ه کیف پول شما افزوده شد",
                        "HTML",
                        true,
                        null,
                        true,
                        null
                    );

                    $telegram->SendMessage(
                        $from_id,
                        "مبلغ 40,000 تومان بابت ثبت کد معرف به کیف پول شما افزوده شد",
                        "HTML",
                        true,
                        null,
                        true,
                        null
                    );
                }
            }

            $telegram->SendMessage(
                $from_id,
                $success_pay_text,
                "HTML",
                true,
                $start_btn,
                true,
                null
            );

            $func->update_payment_by_order_id($order_id, "status", 1);
            $func->update_user($from_id, "status", "start");
            $func->update_user($from_id, "extra_info", "");
            $func->charge_user($from_id, ($price / 10), "-");
        } else {
            $low_wallet_balance_text = str_replace("VIP", $type_subscription, $low_wallet_balance_text);
            $telegram->SendMessage(
                $from_id,
                $low_wallet_balance_text,
                "HTML",
                true,
                null,
                true,
                null
            );
            exit();
        }
        break;

    case $start_btn_18_response_btn_2:

        $telegram->SendPhoto(
            $from_id,
            $start_btn_18_response_btn_2_photo,
            $start_btn_18_response_btn_2_text,
            "Markdown",
            true,
            null,
            null
        );
        exit();
        break;
    case $start_btn_18_response_btn_3:

        $telegram->SendPhoto(
            $from_id,
            $start_btn_18_response_btn_3_photo,
            $start_btn_18_response_btn_3_text,
            "Markdown",
            true,
            null,
            null
        );
        exit();
        break;
    case $start_btn_15_response_btn_3:

        $func->update_user($from_id, "status", "free_order_menu");
        $free_order_can = 1 - (int)$info_user->free_order + floor((int)$info_user->free_order_invite);
        $start_btn_15_response_btn_3_text = str_replace("FREE_ORDER", $free_order_can, $start_btn_15_response_btn_3_text);
        $start_btn_15_response_btn_3_text = str_replace("LINK", "https://t.me/fileechbot?start=$from_id", $start_btn_15_response_btn_3_text);
        $telegram->SendMessage(
            $from_id,
            $start_btn_15_response_btn_3_text,
            "HTML",
            true,
            null,
            true,
            null
        );
        exit();

        break;
    case $start_btn_15_response_btn_1:
        $func->update_user($from_id, "status", "free_order_menu");
        $free_order_can = 1 - (int)$info_user->free_order + floor((int)$info_user->free_order_invite);

        if ($free_order_can < 1) {
            $telegram->SendMessage(
                $from_id,
                $use_fileech_party_text,
                "HTML",
                true,
                null,
                true,
                null
            );
            exit();
        }

        $telegram->SendMessage(
            $from_id,
            $start_btn_15_response_btn_1_text,
            "HTML",
            true,
            $btn_back_to_last_menu_btn,
            true,
            null
        );
        $func->update_user($from_id, "status", "free_order");
        break;
    case $start_btn_9_response_btn_2:
        $info = explode("-", $text);
        $get_files = $func->Get_UserFiles($from_id, 0);
        if ($get_files !== false) {
            $text_to_send = $get_files[1];
            $btn_to_send = ["inline_keyboard" => $get_files[0]];
            $telegram->SendMessage(
                $from_id,
                $text_to_send,
                "HTML",
                true,
                $btn_to_send,
                true,
                null
            );
        } else {
            $telegram->SendMessage(
                $from_id,
                "شما تا کنون سفارش فایل نداشته اید",
                "HTML",
                true,
                null,
                true,
                null
            );

        }
        exit();
        break;
    case $start_btn_9_response_btn_1:
        $info = explode("-", $text);
        $get_payments = $func->Get_UserPayments($from_id, 0);
        if ($get_payments !== false) {
            $text_to_send = $get_payments[1];
            $btn_to_send = ["inline_keyboard" => $get_payments[0]];
            $telegram->SendMessage(
                $from_id,
                $text_to_send,
                "HTML",
                true,
                $btn_to_send,
                true,
                null
            );
        } else {
            $telegram->SendMessage(
                $from_id,
                "شما تا کنون پرداختی نداشته اید",
                "HTML",
                true,
                null,
                true,
                null
            );

        }
        exit();
        break;
    case "ثبت سفارش":
        $user_info = $func->get_user($from_id);
        if ($user_info->status !== "ordercount2") {
            exit();
        }

        $func->update_user($from_id, "status", "start");
        $extra_info2 = json_decode($user_info->extra_info2, true);
        $site_info = $func->get_group_order_price_by_id((int)$extra_info2["site"]);
        $links = $extra_info2["links"];
        $invoice_price = count($links) * $site_info->order_group;

        if ($user_info->wallet >= $invoice_price) {
            $open_order_count = $func->get_files_open_by_chat_id($from_id);
            if ($open_order_count > 0) {
                $telegram->SendMessage(
                    $from_id,
                    "شما سفارش باز دارید. لطفا تا اتمام دریافت سفارش منتظر بمانید",
                    "HTML",
                    true,
                    null,
                    true,
                    null
                );
                exit();
            }
            $inserted_group_file = $func->add_file_group(
                json_encode($links),
                (int)$extra_info2["site"],
                $msgid,
                $from_id,
                $invoice_price
            );
            $file_codes = "";
            $link_counted = 1;
            foreach ($links as $link) {
                if ($link_counted > 10) {
                    unset($links[$link_counted - 1]);
                    continue;
                }
                $file_info = $func->get_link_info($link);
                $file_codes .= $file_info["file_code"] . "\n";
                $link_counted++;
            }
            $text_to_send = "تعداد " . count($links) . " لینک از سایت " . $site_info->site . " ثبت شد.
مبلغ " . $invoice_price . " تومان از موجودی شما کسر شد.

لیست فایل های درخواستی : 
" . $file_codes . "
تمامی فایل ها به زودی برای شما ارسال خواهند شد.";

            $func->charge_user($from_id, $invoice_price, "-");

            $msgid = $telegram->SendMessage(
                $from_id,
                $text_to_send,
                "HTML",
                true,
                $order_submitted_btn,
                true,
                null
            )["result"]["message_id"];

            $insert_file = 0;
            ignore_user_abort(true);
            fastcgi_finish_request();
            // Accidental flush()es won't do harm (even if they're still technically a bug)
            flush();
            foreach ($links as $link) {
                try {
                    $file_info = $func->get_link_info($link);
                    $file_codes .= $file_info["file_code"] . "\n";
                    $preview_link = file_get_contents(
                        "https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/preview.php?url=" . $link
                    );
                    $preview_link = json_decode($preview_link, true);

                    $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                    $preview_type = "photo";

                    if ($preview_link["result"] == true || is_array($preview_link)) {
                        $preview_photo = $preview_link["url"];
                        $preview_type = $preview_link["type"];
                    }

                    $insert_file = $func->add_file(
                        $link,
                        $from_id,
                        $msgid,
                        $from_id,
                        $preview_photo,
                        $preview_type
                    );

                    $func->update_file_info('file_code',$file_info["file_code"], $insert_file);
                    $func->update_file_info('file_name',$file_info["file_name"], $insert_file);
                    $func->update_file_info('count_order_info', $inserted_group_file, $insert_file);

                    $func->update_file_info('status', 'sending', $insert_file);
                    $func->update_file_info('price', $site_info->order_group, $insert_file);

                    $check_exsist_file = $func->check_exsist_file($link);

                    if (is_array($check_exsist_file) && $check_exsist_file[3] == "sent") {

                        $file_info = $func->get_file_compeleted_by_link($link)[0];

                        $func->update_file(
                            $file_info->link,
                            $file_info->type,
                            $file_info->file_id,
                            $file_info->caption,
                            $file_info->ext
                        );

                        $type = $file_info->type;
                        $text_send = $file_info->caption;
                        $file_id = $file_info->file_id;

                        if ($type == "text") {
                            $telegram->SendMessage(
                                $from_id,
                                $text_send,
                                "HTML",
                                true,
                                null,
                                true,
                                $msgid
                            );
                        } else {
                            $file_link = $func->get_file_by_id((int)$insert_file)[0];
                            $request_price = $file_link->price;
                            $open_order_count = $func->get_files_open_by_chat_id($file_link->chat_id);
                            $message = "
📍سفارش های باز/تکمیل نشده: ($open_order_count / 10) 

💵هزینه سفارش : " . number_format($request_price) . " تومان
📁کد فایل : " . $file_link->file_code . "
#️⃣کد پیگیری : " . $file_link->id . "
⚙️وضعیت:  سفارش ارسال شد

❗️توجه: با عرض پوزش قابلیت دریافت لینک دانلود مستقیم موقتا غیرفعال می‌باشد، برای دریافت لینک دانلود مستقیم، کد پیگیری سفارش را برای پشتیبانی ارسال کنید.


👨🏻‍💻پشتیبانی: @FileechAdmin
";
                            $s = $telegram->Send_file(
                                $file_link->preview_type,
                                $file_link->preview,
                                $file_link->chat_id,
                                $file_link->msg_id,
                                $message,
                                null,
                                "HTML"
                            );


                            $func->update_file_info('msg_id', $s["result"]["message_id"], $file_link->id);

                            $target_btn = [
                                "inline_keyboard" => [
                                    [
                                        [
                                            "text" => "دریافت لینک دانلود مستقیم",
                                            "callback_data" => "Directlink_" . $insert_file
                                        ],
                                    ],
                                ],
                            ];
                            $telegram->Send_file(
                                "document",
                                $file_link->file_id,
                                $from_id,
                                $s["result"]["message_id"],
                                null,
                                $target_btn,
                                "HTML"
                            );

                        }
                        $func->update_file_info('price', $site_info->order_group, $insert_file);
                        $func->update_file_info('status', 'sent', $insert_file);

                    } else {
                        ignore_user_abort(true);
                        fastcgi_finish_request();
                        // Accidental flush()es won't do harm (even if they're still technically a bug)
                        flush();

                        $auto_send_text = "";
                        if ($site_info->count_order_automatic_status == 1) {
                            $request_api = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step1.php?url=" . urlencode($link)), true);
                            if ($request_api["ok"] == true) {
                                $func->update_file_info('extra_info',json_encode($request_api["output"]), $insert_file);

                                $slug = $request_api["output"]["slug"];
                                $id = $request_api["output"]["id"];
                                $ispre = $request_api["output"]["ispre"];
                                $typee = $request_api["output"]["type"];

                                $request_api_complete = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step2.php?slug=$slug&id=$id&ispre=$ispre&type=$typee"), true);

                                while ($request_api_complete["ok"] !== true) {

                                    $send = $telegram->SendMessage($chat_id, $request_api_complete["ok"], "HTML", true, null, true, $msgid);
                                    if ($request_api_complete["response"]["title"] == "Have error when download") {
                                        $func->charge_user($from_id, $site_info->order_group, "+");
                                        $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود به وجود آمد. مبلغ " . $site_info->order_group . " تومان بابت لینک \n." . $link . "\n به اعتبار شما اضافه شد", "HTML", true, null, true, $msgid);
                                        $func->delete_file($link);
                                        exit();
                                    }
                                    $request_api_complete = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step2.php?slug=$slug&id=$id&ispre=$ispre&type=$typee"), true);

                                }
                                $download_link = $request_api_complete["link"];
                                $ext = $request_api_complete["ext"];
                                $auto_send_text .= "سفارش تعدادی اتوماتیک api خارجی\nلینک دانلود : $download_link\n";
                            } else {
                                $func->charge_user($from_id, $site_info->order_group, "+");
                                $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود به وجود آمد. مبلغ " . $site_info->order_group . " تومان بابت لینک \n." . $link . "\n به اعتبار شما اضافه شد", "HTML", true, null, true, $msgid);
                                $func->delete_file($link);
                                continue;
                            }
                        }
                        $address_explode = explode("/", $link);
                        $site_name = $address_explode[2];
                        $site_name = str_replace("www.", "", $site_name);
                        if ($site_name == "shutterstock.com" && $site_info->count_order_automatic_status == 0) {

                            $key_api = "87f1f178c4d86e5143fa77857120025a";
                            $file_id = $func->get_link_info($link)["file_code"];
                            $user_id = 1749600986;
                            $request_api = json_decode(file_get_contents("https://eliteprogrammer.ir/Shutterstock/V2/NewOrder.php?key=$key_api&file_id=$file_id&user_id=$user_id"), true);
                            if ($request_api["error"] == false) {
                                $order_id = $request_api["order_id"];
                                $func->update_file_info('extra_info',json_encode($request_api), $insert_file);
                                $request_api_complete = json_decode(file_get_contents("https://eliteprogrammer.ir/Shutterstock/V2/CheckOrder.php?key=$key_api&order_id=$order_id&user_id=$user_id"), true);

                                $timenow = time();

                                while ($request_api_complete["ok"] !== true) {
                                    if (time() > ($timenow + 600)) {
                                        $func->charge_user($from_id, $site_info->order_group, "+");
                                        $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود به وجود آمد. مبلغ " . $request_price . " تومان به اعتبار شما اضافه شد", "HTML", true, null, true, $msgid);
                                        $func->delete_file($link);
                                        exit();
                                    }
                                    if ($request_api_complete["message"] !== "order not process yet") {
                                        $func->update_file_info('extra_info',json_encode($request_api_complete), $insert_file);
                                    }
                                    $request_api_complete = json_decode(file_get_contents("https://eliteprogrammer.ir/Shutterstock/V2/CheckOrder.php?key=$key_api&order_id=$order_id&user_id=$user_id"), true);
                                }

                                $download_link = $request_api_complete["download_link"];
                                $ext = explode("?", pathinfo($download_link, PATHINFO_EXTENSION))[0]; // to get extension
                                $ext = explode("&", $ext)[0];
                                $auto_send_text .= "سفارش تعدادی اتوماتیک api ایرانی\nلینک دانلود : $download_link\n\n";
                            }
                        }

                        $btn_for_admin = [
                            "inline_keyboard" => [
                                [
                                    [
                                        "text" => "ارسال فایل",
                                        "callback_data" =>
                                            "send_file_single:" .
                                            $insert_file .
                                            ":$from_id",
                                    ],
                                ],
                            ],
                        ];
                        $get_order_single_text_adminn = str_replace(
                            "USER",
                            "<a href=\"tg://user?id=$from_id\">$from_id</a>",
                            $get_order_single_text_admin
                        );
                        $get_order_single_text_adminn = str_replace(
                            "OPENCHAT",
                            "tg://openmessage?user_id=$from_id",
                            $get_order_single_text_adminn
                        );
                        $get_order_single_text_admin = str_replace(
                            "GROUP",
                            "❌",
                            $get_order_single_text_admin
                        );
                        $get_order_single_text_adminn = str_replace(
                            "LINK",
                            $link,
                            $get_order_single_text_adminn
                        );
                        $get_order_single_text_adminn = str_replace(
                            "DATE",
                            jdate("Y/m/d H:i:s"),
                            $get_order_single_text_adminn
                        );
                        $get_order_single_text_adminn = str_replace(
                            "REFID",
                            "s" . $insert_file,
                            $get_order_single_text_adminn
                        );
                        $get_order_single_text_adminn = str_replace(
                            "FILECODE",
                            $file_info["file_code"],
                            $get_order_single_text_adminn
                        );
                        $get_order_single_text_adminn = str_replace(
                            "FILENAME",
                            $file_info["file_name"],
                            $get_order_single_text_adminn
                        );

                        if ($preview_photo == "") {
                            $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                            $preview_type = "photo";
                        }

                        $sended_manage = $telegram->Send_file(
                            $preview_type,
                            $preview_photo,
                            $checking_link,
                            null,
                            $auto_send_text . $get_order_single_text_adminn,
                            $btn_for_admin,
                            "HTML"
                        );

                        if ($sended_manage["ok"] !== true) {

                            $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                            $preview_type = "photo";
                            $sended_manage = $telegram->Send_file(
                                $preview_type,
                                $preview_photo,
                                $checking_link,
                                null,
                                $auto_send_text . $get_order_single_text_adminn,
                                $btn_for_admin,
                                "HTML"
                            );

                            $func->update_file_info('msg_mng', $sended_manage["result"]["message_id"], $insert_file);
                            $func->update_file_info('preview', $preview_photo, $insert_file);
                            $func->update_file_info('preview_type',$preview_type, $insert_file);
                        } else {

                            $func->update_file_info('msg_mng', $sended_manage["result"]["message_id"], $insert_file);
                        }

                        if ($site_name == "shutterstock.com" || $site_info->count_order_automatic_status == 1) {
                            $send2 = $telegram->SendMessage(
                                $checking_link,
                                "Downloading ...",
                                "HTML",
                                true,
                                null,
                                true,
                                $sended_manage["result"]["message_id"]
                            );

                            $func->update_file_info('status_msgid', $send2["result"]["message_id"], $insert_file);
                            $func->update_file_info('status', 'sending', $insert_file);
                            $func->update_file_info('download_link', $download_link, $insert_file);
                            $func->update_file_info('ext',$ext, $insert_file);
                            $file_link = $func->get_file_by_id((int)$insert_file)[0];
                            if ($file_link->chat_id == $file_link->user_id) {
                                $request_price = $file_link->price;
                                $open_order_count = $func->get_files_open_by_chat_id($file_link->chat_id);
                                $message = "
📍سفارش های باز/تکمیل نشده: ($open_order_count / 10) 

💵هزینه سفارش : " . number_format($request_price) . " تومان
📁کد فایل : " . $file_link->file_code . "
#️⃣کد پیگیری : " . $file_link->id . "

⚙️وضعیت:  سفارش ثبت شد

👨🏻‍💻پشتیبانی: @FileechAdmin
";
                                $s = $telegram->Send_file(
                                    $file_link->preview_type,
                                    $file_link->preview,
                                    $file_link->chat_id,
                                    $file_link->msg_id,
                                    $message,
                                    null,
                                    "HTML"
                                );

                                $func->update_file_info('msg_id', $s["result"]["message_id"], $file_link->id);
                            }

                            if ($func->get_meta_data("send_order_way") == "py") {

                                shell_exec('nohup python3 /home/fileechbot/public_html/fileech_prime/python/fileecher2.py ' . $insert_file . ' > /dev/null 2>/dev/null &');
                            } else {
                                file_get_contents("https://fileechbot.ir/file_uploader/index.php?id=" . $insert_file);
                            }
                            sleep(30);

                        }
                    }
                } catch (Exception $e) {
                    error_log('Caught exception: ', $e->getMessage(), "\n");
                }
            }
        } else {
            $charge_wallet_keyboard = ['keyboard' =>
                [
                    [$start_btn_text_16],
                    [$start_btn_text_11]
                ], "resize_keyboard" => true];
            $charge_wallet_text = "\n ❌موجودی کیف پول شما کافی نمی‌باشد،
 
جمع کل: " . $invoice_price . " تومان
موجودی کیف پول شما: " . $user_info->wallet . " تومان
";

            $telegram->SendMessage(
                $from_id,
                $charge_wallet_text,
                "HTML",
                true,
                $charge_wallet_keyboard,
                true,
                null
            );
        }

        exit();
        break;
    case "ثبت سفارش رایگان":
        if ($info_user->verified !== "ok") {
            $telegram->SendMessage(
                $from_id,
                $enter_number_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact3");
            exit();
        }
        $user_info = $func->get_user($from_id);
        $free_order_can = 1 - (int)$user_info->free_order + floor((int)$user_info->free_order_invite);

        if ($user_info->status !== "free_order2" || $free_order_can < 1) {
            exit();
        }

        if ($user_info->free_order == 0) {
            $func->update_user($from_id, "free_order", 1);
        } else {
            $func->update_user($from_id, "free_order_invite", (double)$user_info->free_order_invite - (double)1);
        }
        $func->update_user($from_id, "status", "start");
        $link = $user_info->extra_info2;
        $file_info = $func->get_link_info($link);
        $site_info = [];
        if ($file_info["site"] == "freepik") {

            $site_info = $func->get_group_order_price_by_id(1);
        } else {
            $site_info = $func->get_group_order_price_by_id(2);
        }
        $file_codes = $file_info["file_code"] . "\n";
        $text_to_send = "تعداد 1 لینک از سایت " . $file_info["real_site"] . " ثبت شد.

فایل درخواستی : 
" . $file_codes . "
لینک دانلود بزودی برای شما ارسال خواهد شد";

        $msgid = $telegram->SendMessage(
            $from_id,
            $text_to_send,
            "HTML",
            true,
            $start_btn,
            true,
            null
        )["result"]["message_id"];

        $preview_link = file_get_contents(
            "https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/preview.php?url=" . $link
        );
        $preview_link = json_decode($preview_link, true);
        $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
        $preview_type = "photo";

        if ($preview_link["result"] == true || is_array($preview_link)) {
            $preview_type = $preview_link["type"];
            $preview_photo = $preview_link["url"];
        }

        $insert_file = $func->add_file(
            $link,
            $from_id,
            $msgid,
            $from_id,
            $preview_photo,
            $preview_type
        );

        $func->update_file_info('file_code',$file_info["file_code"], $insert_file);
        $func->update_file_info('file_name',$file_info["file_name"], $insert_file);
        $func->update_file_info('count_order_info', 0, $insert_file);
        $check_exsist_file = $func->check_exsist_file($link);
        if (is_array($check_exsist_file) && $check_exsist_file[3] == "sent") {
            $file_info = $func->get_file_by_link($link)[0];
            $func->update_file(
                $file_info->link,
                $file_info->type,
                $file_info->file_id,
                $file_info->caption,
                $file_info->ext
            );

            $type = $file_info->type;
            $text_send = $file_info->caption;
            $file_id = $file_info->file_id;

            if ($type == "text") {
                $telegram->SendMessage(
                    $from_id,
                    $text_send,
                    "HTML",
                    true,
                    null,
                    true,
                    $msgid
                );
            } else {
                $target_btn = [
                    "inline_keyboard" => [
                        [
                            [
                                "text" => "دریافت لینک دانلود مستقیم",
                                "callback_data" => "Directlink_" . $insert_file
                            ],
                        ],
                    ],
                ];
                $telegram->Send_file(
                    $type,
                    $file_id,
                    $from_id,
                    $msgid,
                    $text_send,
                    $target_btn,
                    "HTML"
                );
            }
            $func->update_file_info('price', 0, $insert_file);
            $func->update_file_info('status','sent', $insert_file);

        } else {
            ignore_user_abort(true);
            fastcgi_finish_request();
            // Accidental flush()es won't do harm (even if they're still technically a bug)
            flush();

            $auto_send_text = "";
            if ($site_info->count_order_automatic_status == 1) {
                $request_api = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step1.php?url=" . urlencode($link)), true);
                if ($request_api["ok"] == true) {
                    $func->update_file_info('extra_info',json_encode($request_api["output"]), $insert_file);

                    $slug = $request_api["output"]["slug"];
                    $id = $request_api["output"]["id"];
                    $ispre = $request_api["output"]["ispre"];
                    $typee = $request_api["output"]["type"];

                    $request_api_complete = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step2.php?slug=$slug&id=$id&ispre=$ispre&type=$typee"), true);

                    while ($request_api_complete["ok"] !== true) {

                        $send = $telegram->SendMessage($chat_id, $request_api_complete["ok"], "HTML", true, null, true, $msgid);
                        if ($request_api_complete["response"]["title"] == "Have error when download") {
                            $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود بوجود آمد ، شما میتوانید مجددا درخواست خود را ارسال کنید", "HTML", true, null, true, $msgid);
                            $func->delete_file($link);
                            $func->update_user($from_id, "free_order", 0);
                            exit();
                        }
                        $request_api_complete = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step2.php?slug=$slug&id=$id&ispre=$ispre&type=$typee"), true);

                    }
                    $download_link = $request_api_complete["link"];
                    $ext = $request_api_complete["ext"];

                    $func->update_file_info('download_link',$download_link, $insert_file);
                    $func->update_file_info('ext',$ext, $insert_file);
                    $auto_send_text .= "سفارش رایگان تست اتوماتیک api خارجی\nلینک دانلود : $download_link\n";
                } else {
                    $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود بوجود آمد ، شما میتوانید مجددا درخواست خود را ارسال کنید", "HTML", true, null, true, $msgid);
                    $func->delete_file($link);
                    $func->update_user($from_id, "free_order", 0);
                    exit();
                }
            }

            $btn_for_admin = [
                "inline_keyboard" => [
                    [
                        [
                            "text" => "ارسال فایل",
                            "callback_data" =>
                                "send_file_single:" .
                                $insert_file .
                                ":$from_id",
                        ],
                    ],
                ],
            ];
            $get_order_single_text_admin = str_replace(
                "USER",
                "<a href=\"tg://user?id=$from_id\">$from_id</a>",
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "OPENCHAT",
                "tg://openmessage?user_id=$from_id",
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "GROUP",
                "❌",
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "LINK",
                $link,
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "DATE",
                jdate("Y/m/d H:i:s"),
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "REFID",
                "s" . $insert_file,
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "FILECODE",
                $file_info["file_code"],
                $get_order_single_text_admin
            );
            $get_order_single_text_admin = str_replace(
                "FILENAME",
                $file_info["file_name"],
                $get_order_single_text_admin
            );
            if ($preview_photo == "") {
                $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                $preview_type = "photo";
                $func->update_file_info('preview', $preview_photo, $insert_file);
                $func->update_file_info('preview_type',$preview_type, $insert_file);

            }

            $sended_manage = $telegram->Send_file(
                $preview_type,
                $preview_photo,
                $checking_link,
                null,
                $auto_send_text . $get_order_single_text_admin,
                $btn_for_admin,
                "HTML"
            );

            if ($sended_manage["ok"] !== true) {

                $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                $preview_type = "photo";
                $sended_manage = $telegram->Send_file(
                    $preview_type,
                    $preview_photo,
                    $checking_link,
                    null,
                    $auto_send_text . $get_order_single_text_admin,
                    $btn_for_admin,
                    "HTML"
                );

                $func->update_file_info('msg_mng', $sended_manage["result"]["message_id"], $insert_file);
                $func->update_file_info('preview', $preview_photo, $insert_file);
                $func->update_file_info('preview_type',$preview_type, $insert_file);
            } else {

                $func->update_file_info('msg_mng', $sended_manage["result"]["message_id"], $insert_file);
            }

            if ($site_info->count_order_automatic_status == 1) {
                $send2 = $telegram->SendMessage(
                    $checking_link,
                    "Downloading ...",
                    "HTML",
                    true,
                    null,
                    true,
                    $sended_manage["result"]["message_id"]
                );

                $func->update_file_info('status_msgid', $send2["result"]["message_id"], $insert_file);

                $func->update_file_info('status', 'sending', $insert_file);
                $func->update_file_info('download_link', $download_link, $insert_file);
                $func->update_file_info('ext',$request_api_complete["ext"], $insert_file);
                $file_link = $func->get_file_by_id((int)$insert_file)[0];

                if ($file_link->chat_id == $file_link->user_id) {
                    $request_price = $file_link->price;
                    $open_order_count = $func->get_files_open_by_chat_id($file_link->chat_id);
                    $message = "
📍سفارش های باز/تکمیل نشده: ($open_order_count / 10) 

💵هزینه سفارش : رایگان
📁کد فایل : " . $file_link->file_code . "
#️⃣کد پیگیری : " . $file_link->id . "

⚙️وضعیت:  سفارش ثبت شد

👨🏻‍💻پشتیبانی: @FileechAdmin
";
                    $s = $telegram->Send_file(
                        $file_link->preview_type,
                        $file_link->preview,
                        $file_link->chat_id,
                        $file_link->msg_id,
                        $message,
                        null,
                        "HTML");

                    $func->update_file_info('msg_id', $s["result"]["message_id"], $file_link->id);
                }
                //shell_exec ('nohup python3 /home/fileechbot/public_html/fileech_prime/python/fileecher2.py ' . $insert_file . ' > /dev/null 2>/dev/null &');
                if ($func->get_meta_data("send_order_way") == "py") {
                    error_log($insert_file);
                    shell_exec('nohup python3 /home/fileechbot/public_html/fileech_prime/python/fileecher2.py ' . $insert_file . ' > /dev/null 2>/dev/null &');
                } else {
                    file_get_contents("https://fileechbot.ir/file_uploader/index.php?id=" . $insert_file);
                }


            }
        }

        $func->update_user($from_id, "status", "start");
        exit();
        break;
    case "انصراف":
        $telegram->deleteMessage($from_id, $msgid);
        $aceepted_file_codes = "";
        $user_info = $func->get_user($from_id);
        $extra_info2 = json_decode($user_info->extra_info2, true);
        $accepted_links_array = [];
        $links = [];

        $linkde_count = 1;
        foreach ($extra_info2["links"] as $link) {
            if ($linkde_count > 10) {
                break;
            }
            $links[] = $link;
            $linkde_count++;
        }
        foreach ($links as $link) {

            $link = trim($link);
            if (filter_var($link, FILTER_VALIDATE_URL)) {
                $allowed = $func->get_count_order_site_price($link);
                if ($allowed !== false || $allowed->id == (int)$extra_info2["site"]) {
                    $accepted_links_array[] = $link;
                    $aceepted_file_codes .= $func->get_link_info($link)["file_code"] . "\n";
                }
            }
        }
        if (count($accepted_links_array) > 0) {
            $site_info = $func->get_group_order_price_by_id((int)$extra_info2["site"]);
            $invoice_price = count($accepted_links_array) * $site_info->order_group;

            $order_count_level_2_text = str_replace("LINK_COUNT", count($accepted_links_array), $order_count_level_2_text);
            $order_count_level_2_text = str_replace("SITENAME", $site_info->site, $order_count_level_2_text);
            $order_count_level_2_text = str_replace("FILE_CODES", $aceepted_file_codes, $order_count_level_2_text);

            $submit_order_keyboard = ['keyboard' =>
                [
                    ["ثبت سفارش", "افزودن لینک های بیشتر"],
                    [$start_btn_text_11]
                ], "resize_keyboard" => true];

            if ($user_info->wallet < $invoice_price) {
                $submit_order_keyboard = ['keyboard' =>
                    [
                        [$start_btn_text_16],
                        [$start_btn_text_11]
                    ], "resize_keyboard" => true];
                $order_count_level_2_text .= "\n ❌موجودی کیف پول شما کافی نمی‌باشد،
 
جمع کل: " . $invoice_price . " تومان
موجودی کیف پول شما: " . $user_info->wallet . " تومان
";
            } else {
                $order_count_level_2_text .= "\n ✅ با انتخاب دکمه ثبت سفارش مبلغ " . $invoice_price . " تومان از موجودی کیف پول شما کم خواهد شد.";

                $func->update_user($from_id, "extra_info2", json_encode(['site' => (int)$extra_info2["site"], 'links' => $accepted_links_array]));
            }
            $telegram->SendMessage(
                $from_id,
                $order_count_level_2_text,
                "HTML",
                true,
                $submit_order_keyboard,
                true,
                null
            );
            $func->update_user($from_id, "status", "ordercount2");
            exit();
        } else {
            $telegram->SendMessage(
                $from_id,
                $there_is_no_accepted_link,
                "HTML",
                true,
                $btn_back_to_main_menu_btn,
                true,
                null
            );
            exit();
        }
        break;
    case $order_submitted_btn_text_1:
        $data = json_decode($info_user->extra_info2, true);
        $site_info = $func->get_group_order_price_by_id((int)$data["site"]);
        if ($site_info !== false) {

            $order_count_level_1_text = str_replace("PRICE_NORMAL", $site_info->order_group, $order_count_level_1_text);
            //$order_count_level_1_text = str_replace ("PRICE_PRIME", $site_info->price_manual, $order_count_level_1_text);

            $telegram->SendMessage(
                $from_id,
                $site_info->order_group_text . $order_count_level_1_text,
                "markdown",
                true,
                $btn_back_to_main_menu_btn,
                true,
                null
            );
        }

        $func->update_user($from_id, "status", "ordercount");
        $func->update_user($from_id, "extra_info2", $site_info->id);
        exit();
        break;
    case "افزودن لینک های بیشتر":
        $data = json_decode($info_user->extra_info2, true);
        $site_info = $func->get_group_order_price_by_id((int)$data["site"]);
        if ($site_info !== false) {

            $order_count_level_1_text = str_replace("PRICE_NORMAL", $site_info->order_group, $order_count_level_1_text);
            //$order_count_level_1_text = str_replace ("PRICE_PRIME", $site_info->price_manual, $order_count_level_1_text);

            $telegram->SendMessage(
                $from_id,
                $site_info->order_group_text . $order_count_level_1_text,
                "markdown",
                true,
                $canceladdmorelinks_inlineKeyboard,
                true,
                null
            );
        }
        $func->update_user($from_id, "status", "addmorelink");
        exit();
        
        break;
    case "/start":
        if (isset($update->callback_query->data)) {
            $telegram->deleteMessage($from_id, $msgid);
        }
        $user_mention =
            '<a href="tg://user?id=' . $from_id . '">' . $first_name . "</a>";
        $start_text = str_replace("USER", $user_mention, $start_text);
        $telegram->SendMessage(
            $from_id,
            $start_text,
            "HTML",
            true,
            $start_btn,
            true,
            null
        );
        $func->update_user($from_id, "status", "start");
        exit();
        break;
    case $start_btn_text_14:
    case $order_submitted_btn_text_2:
        $start_btn_14_response_inlineKeyboard = ["keyboard" => $func->count_order_sites(),
            "resize_keyboard" => true];

        $telegram->SendMessage(
            $from_id,
            $start_btn_14_response_text,
            "HTML",
            true,
            $start_btn_14_response_inlineKeyboard,
            true,
            null
        );

        $func->update_user($from_id, "status", "start_ordercount");
        break;
    case $start_btn_text_11:
        $user_mention =
            '<a href="tg://user?id=' . $from_id . '">' . $first_name . "</a>";
        $start_text = str_replace("USER", $user_mention, $start_text);
        $telegram->SendMessage(
            $from_id,
            $start_text,
            "HTML",
            true,
            $start_btn,
            true,
            null
        );
        $func->update_user($from_id, "status", "start");
        exit();
        break;

    case $start_btn_text_1:
        $telegram->SendPhoto(
            $from_id,
            $start_btn_1_response_photo,
            $start_btn_1_response_text,
            "Markdown",
            true,
            null,
            null
        );
        exit();
        break;

    case $start_btn_text_2:
        $telegram->SendPhoto(
            $from_id,
            $start_btn_2_response_photo,
            $start_btn_2_response_text,
            "Markdown",
            true,
            null,
            null
        );
        exit();
        break;

    case $start_btn_text_3:
        $telegram->SendPhoto(
            $from_id,
            $start_btn_3_response_photo,
            $start_btn_3_response_text,
            "Markdown",
            true,
            null,
            null
        );
        exit();
        break;

    case $start_btn_text_4:
        $telegram->SendPhoto(
            $from_id,
            $start_btn_4_response_photo,
            $start_btn_4_response_text,
            "Markdown",
            true,
            null,
            null
        );
        exit();
        break;
    case $start_btn_text_5:
        if ($func->check_user_has_prime($from_id)) {
            $start_btn_5_response_text = str_replace("INVITER_CODE", $from_id, $start_btn_5_response_text);
            $telegram->SendMessage(
                $from_id,
                $start_btn_5_response_text,
                "HTML",
                true,
                $start_btn,
                true,
                null
            );
        } else {
            $telegram->SendMessage(
                $from_id,
                "برای دعوت دوستانتان میبایست اشتراک پرایم خریداری کرده باشید و حداقل 20 هزار تومان از اعتبار پرایم شما باقیمانده باشد",
                "HTML",
                true,
                $start_btn,
                true,
                null
            );
        }
        exit();

        break;

    case $start_btn_text_6:
        $telegram->SendPhoto(
            $from_id,
            $start_btn_6_response_photo,
            $start_btn_6_response_text,
            "Markdown",
            true,
            null,
            $start_btn_6_7_response_inlineKeyboard
        );
        exit();
        break;

    case $start_btn_text_7:
        $telegram->SendPhoto(
            $from_id,
            $start_btn_7_response_photo,
            $start_btn_7_response_text,
            "Markdown",
            true,
            null,
            $start_btn_6_7_response_inlineKeyboard
        );
        exit();
        break;

    case $start_btn_text_8:
        $telegram->SendMessage(
            $from_id,
            $start_btn_8_response_text,
            "Markdown",
            true,
            $start_btn_8_response_keyboard,
            true,
            null
        );
        exit();

        break;
    case $start_btn_text_9:

        $start_btn_9_response_text = str_replace("USERID", $from_id, $start_btn_9_response_text);
        $start_btn_9_response_text = str_replace("CREDIT", $info_user->wallet . " تومان", $start_btn_9_response_text);

        $telegram->SendMessage(
            $from_id,
            $start_btn_9_response_text,
            "HTML",
            true,
            $start_btn_9_response_keyboard,
            true,
            null
        );
        exit();
        break;
    case $start_btn_text_16:
        if (isset($update->callback_query->data)) {
            $telegram->deleteMessage($from_id, $msgid);
        }
        if ($info_user->verified !== "ok") {
            $telegram->SendMessage(
                $from_id,
                $enter_number_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact2");
            exit();
        }
        $telegram->SendMessage(
            $from_id,
            $enter_amount_charge_text,
            "HTML",
            true,
            $enter_amount_charge_keyboard,
            true,
            null
        );

        $func->update_user($from_id, "status", "wallet_charge");
        exit();
        break;
    case $start_btn_text_10:
        $telegram->SendMessage(
            $from_id,
            $order_unlimit_text,
            "HTML",
            true,
            $order_unlimit_btn,
            true,
            null
        );
        exit();
        break;

    case $start_btn_text_12:
        $start_btn_12_response_keyboard = [
            "keyboard" =>

                $func->get_primes('prime')
            ,
            "resize_keyboard" => true,
        ];
                $telegram->SendPhoto(
            $from_id,
            $photo_btn_12_response_photo,
            $start_btn_12_response_text,
            "Markdown",
            true,
            null,
            $start_btn_12_response_keyboard
        );

        $func->update_user($from_id, "status", "buy_prime");
        exit();
        break;
    case $start_btn_text_18:

        $telegram->SendMessage(
            $from_id,
            $start_btn_18_response_text,
            "HTML",
            false,
            $start_btn_18_response_keyboard,
            false,
            false
        );

        exit();
        break;
    case $start_btn_18_response_btn_1:
        $start_btn_18_response_btn_1_keyboard = [
            "keyboard" =>

                $func->get_primes('suggest')
            ,
            "resize_keyboard" => true,
        ];
        $telegram->SendMessage(
            $from_id,
            $start_btn_18_response_btn_1_text,
            "HTML",
            false,
            $start_btn_18_response_btn_1_keyboard,
            false,
            false
        );

        $func->update_user($from_id, "status", "buy_prime2");
        exit();
        break;

    case $start_btn_text_13:
        $func->update_user($from_id, "inviter", "1");
        if ($info_user->verified !== "ok") {
            $telegram->SendMessage(
                $from_id,
                $enter_number_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact");
            exit();
        }
        $payment_link = json_decode(file_get_contents("https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/request_pay.php?u=$from_id&p=prime_" . $info_user->extra_info));
        if ($payment_link->ok == false) {
            $telegram->SendMessage(
                $from_id,
                $error_generate_payment_link_text,
                "HTML",
                true,
                null,
                true,
                null
            );
            exit();
        }
        $price = 0;
        $prime = $func->get_primes_by_id($plan);
        if ($prime == false) {
            echo json_encode(['ok' => false, "message" => "invalid plan"]);
            exit();
        }
        $type_subscription = $prime->short_name;
        $price = $prime->price * 10;

        $payment_link_generated_text = str_replace("PRICE", number_format($price / 10, 0), $payment_link_generated_text);
        $payment_link_generated_text = str_replace("PAYMENT_LINK", $payment_link->link, $payment_link_generated_text);
        $telegram->SendMessage(
            $from_id,
            $payment_link_generated_text,
            "HTML",
            true,
            $btn_pay_buy_prime_btn,
            true,
            null
        );
        $func->update_user($from_id, "status", "start");
        exit();
        break;

    case $btn_make_payment_link_text:
        if ($info_user->status !== "buy_prime") {
            exit();
        }
        if ($info_user->inviter == 0) {
            $telegram->SendMessage(
                $from_id,
                $enter_inviter_code_text,
                "HTML",
                true,
                $inviter_btn,
                true,
                null
            );

            $func->update_user($from_id, "status", "add_inviter");
            exit();
        }

        if ($info_user->verified !== "ok") {
            $telegram->SendMessage(
                $from_id,
                $enter_number_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact");
            exit();
        }

        $payment_link = json_decode(file_get_contents("https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/request_pay.php?u=$from_id&p=prime_" . $info_user->extra_info));
        if ($payment_link->ok == false) {
            $telegram->SendMessage(
                $from_id,
                $error_generate_payment_link_text,
                "HTML",
                true,
                null,
                true,
                null
            );
            exit();
        }
        $price = 0;
        switch ($info_user->extra_info) {
            case "eco":
                $price = $eco_price * 10;
                break;
            case "basic":
                $price = $basic_price * 10;
                break;
            case "business":
                $price = $bussiness_price * 10;
                break;
        }

        $payment_link_generated_text = str_replace("PRICE", number_format($price / 10, 0), $payment_link_generated_text);
        $payment_link_generated_text = str_replace("PAYMENT_LINK", $payment_link->link, $payment_link_generated_text);

        $telegram->SendMessage(
            $from_id,
            $payment_link_generated_text,
            "HTML",
            true,
            $btn_pay_buy_prime_btn,
            true,
            null
        );
        $func->update_user($from_id, "status", "start");
        break;
}

switch ($info_user->status) {
    case "buy_prime":
    case "buy_prime2":
        $prime = $func->get_primes_by_name($text);
        if ($prime !== false) {
            $func->update_user($from_id, "extra_info", $prime->id);
            $telegram->SendMessage(
                $from_id,
                $prime->description,
                "Markdown",
                false,
                $btn_make_payment_link_btn,
                true,
                null
            );
            exit();
        }
        break;
    case "start_ordercount":
        $site_info = $func->get_group_order_price($text);
        if ($site_info !== false) {

            $order_count_level_1_text = str_replace("PRICE_NORMAL", $site_info->order_group, $order_count_level_1_text);
            //$order_count_level_1_text = str_replace ("PRICE_PRIME", $site_info->price_manual, $order_count_level_1_text);

            $func->update_user($from_id, "status", "ordercount");
            $func->update_user($from_id, "extra_info2", $site_info->id);
            $telegram->SendMessage(
                $from_id,
                $site_info->order_group_text . $order_count_level_1_text,
                "markdown",
                true,
                $btn_back_to_last_menu_btn,
                true,
                null
            );
        }
        break;
    case "addmorelink":

        $links = explode("\n", $text);
        $aceepted_file_codes = "";
        $user_info = $func->get_user($from_id);
        $extra_info2 = json_decode($user_info->extra_info2, true);
        $accepted_links_array = [];

        $func->update_user($from_id, "status", "ordercount2");

        foreach ($extra_info2["links"] as $link) {

            $links[] = $link;

        }
        $linkde_count = 1;
        foreach ($links as $link) {
            if ($linkde_count > 10) {
                break;
            }
            $link = trim($link);
            if (filter_var($link, FILTER_VALIDATE_URL)) {
                $allowed = $func->get_count_order_site_price($link);
                if ($allowed !== false || $allowed->id == (int)$extra_info2["site"]) {
                    $accepted_links_array[] = $link;
                    $aceepted_file_codes .= $func->get_link_info($link)["file_code"] . "\n";
                    $linkde_count++;
                }
            }
        }
        if (count($accepted_links_array) > 0) {
            $site_info = $func->get_group_order_price_by_id((int)$extra_info2["site"]);
            $invoice_price = count($accepted_links_array) * $site_info->order_group;

            $order_count_level_2_text = str_replace("LINK_COUNT", count($accepted_links_array), $order_count_level_2_text);
            $order_count_level_2_text = str_replace("SITENAME", $site_info->site, $order_count_level_2_text);
            $order_count_level_2_text = str_replace("FILE_CODES", $aceepted_file_codes, $order_count_level_2_text);

            $submit_order_keyboard = ['keyboard' =>
                [
                    ["ثبت سفارش", "افزودن لینک های بیشتر"],
                    [$start_btn_text_11]
                ], "resize_keyboard" => true];

            if ($user_info->wallet < $invoice_price) {
                $submit_order_keyboard = ['keyboard' =>
                    [
                        [$start_btn_text_16],
                        [$start_btn_text_11]
                    ], "resize_keyboard" => true];
                $order_count_level_2_text .= "\n ❌موجودی کیف پول شما کافی نمی‌باشد،
 
جمع کل: " . $invoice_price . " تومان
موجودی کیف پول شما: " . $user_info->wallet . " تومان
";
            } else {
                $order_count_level_2_text .= "\n ✅ با انتخاب دکمه ثبت سفارش مبلغ " . $invoice_price . " تومان از موجودی کیف پول شما کم خواهد شد.";

                $func->update_user($from_id, "extra_info2", json_encode(['site' => (int)$extra_info2["site"], 'links' => $accepted_links_array]));
            }
            $telegram->SendMessage(
                $from_id,
                $order_count_level_2_text,
                "HTML",
                true,
                $submit_order_keyboard,
                true,
                null
            );
            exit();
        } else {
            $telegram->SendMessage(
                $from_id,
                $there_is_no_accepted_link,
                "HTML",
                true,
                $btn_back_to_main_menu_btn,
                true,
                null
            );
            exit();
        }
        break;
    case "ordercount":
        $links = explode("\n", $text);
        $accepted_links_array = [];
        $aceepted_file_codes = "";
        $user_info = $func->get_user($from_id);
        $linked_count = 1;
        foreach ($links as $link) {
            if ($linked_count > 10) {
                break;
            }
            $link = trim($link);
            if (filter_var($link, FILTER_VALIDATE_URL)) {
                $allowed = $func->get_count_order_site_price($link);
                if ($allowed !== false || $allowed->id == $user_info->extra_info2) {
                    $accepted_links_array[] = $link;
                    $aceepted_file_codes .= $func->get_link_info($link)["file_code"] . "\n";
                    $linked_count++;
                }
            }
        }
        if (count($accepted_links_array) > 0) {

            $site_info = $func->get_group_order_price_by_id($user_info->extra_info2);
            $invoice_price = count($accepted_links_array) * $site_info->order_group;

            $order_count_level_2_text = str_replace("LINK_COUNT", count($accepted_links_array), $order_count_level_2_text);
            $order_count_level_2_text = str_replace("SITENAME", $site_info->site, $order_count_level_2_text);
            $order_count_level_2_text = str_replace("FILE_CODES", $aceepted_file_codes, $order_count_level_2_text);

            $submit_order_keyboard = ['keyboard' =>
                [
                    ["ثبت سفارش", "افزودن لینک های بیشتر"],
                    [$start_btn_text_11]
                ],
                "resize_keyboard" => true];

            if ($user_info->wallet < $invoice_price) {
                $submit_order_keyboard = ['keyboard' =>
                    [
                        [$start_btn_text_16],
                        [$start_btn_text_11]
                    ],
                    "resize_keyboard" => true];
                $order_count_level_2_text .= "\n ❌موجودی کیف پول شما کافی نمی‌باشد،
 
جمع کل: " . $invoice_price . " تومان
موجودی کیف پول شما: " . $user_info->wallet . " تومان
";
            } else {
                $order_count_level_2_text .= "\n ✅ با انتخاب دکمه ثبت سفارش مبلغ " . $invoice_price . " تومان از موجودی کیف پول شما کم خواهد شد.";

                $func->update_user($from_id, "extra_info2", json_encode(['site' => $user_info->extra_info2, 'links' => $accepted_links_array]));
            }
            $telegram->SendMessage(
                $from_id,
                $order_count_level_2_text,
                "HTML",
                true,
                $submit_order_keyboard,
                true,
                null
            );
            $func->update_user($from_id, "status", "ordercount2");
            exit();
        } else {
            $telegram->SendMessage(
                $from_id,
                $there_is_no_accepted_link,
                "HTML",
                true,
                $btn_back_to_main_menu_btn,
                true,
                true,
                null
            );
            exit();
        }
        break;
    case "free_order":
        $user_info = $func->get_user($from_id);
        $aceepted_file_codes = "";
        $link = trim($text);
        if (filter_var($link, FILTER_VALIDATE_URL)) {
            $link_info = $func->get_link_info($link);
            if ($link_info["site"] == "freepik" or $link_info["site"] == "envato" or $link_info["site"] == "pngtree" or $link_info["site"] == "shutterstock" or $link_info["site"] == "motionarray" or $link_info["site"] == "storyblocks" or $link_info["site"] == "pngtree" && !is_null($link_info["file_code"])) {
  $aceepted_file_codes .= $link_info["file_code"] . "\n";
            } else {
                $telegram->SendMessage($from_id, $free_order_invalid_site_text, "HTML", true, $btn_back_to_last_menu_btn, true, null);
                exit();

            }
        } else {
            $telegram->SendMessage($from_id, $free_order_invalid_link_text, "HTML", true, $btn_back_to_last_menu_btn, true, null);
            exit();
        }

        $free_order_text = str_replace("LINK_COUNT", 1, $free_order_text);
        $free_order_text = str_replace("SITENAME", $link_info["real_site"], $free_order_text);
        $free_order_text = str_replace("FILE_CODES", $aceepted_file_codes, $free_order_text);

        $submit_order_keyboard = ['keyboard' =>
            [
                ["ثبت سفارش رایگان"],
                ["بازگشت به منوی قبلی"]
            ],
            "resize_keyboard" => true];
        $func->update_user($from_id, "extra_info2", $link);

        $telegram->SendMessage($from_id, $free_order_text, "HTML", true, $submit_order_keyboard, true, null);
        $func->update_user($from_id, "status", "free_order2");
        exit();

        break;
    case "add_inviter":
        $text = $func->FatoEn($text);
        if (is_numeric($text)) {
            if ($func->get_user($text) == false) {
                $telegram->SendMessage(
                    $from_id,
                    $inviter_code_not_exists_text,
                    "Markdown",
                    true,
                    null,
                    true,
                    null
                );
                exit();
            }

            if ($func->check_user_has_prime($text) == false) {
                $telegram->SendMessage(
                    $from_id,
                    "امکان استفاده از کد دعوت این کاربر امکان پذیر نیست",
                    "Markdown",
                    true,
                    null,
                    true,
                    null
                );
                exit();
            }

            $telegram->SendMessage(
                $from_id,
                $success_submit_inviter_code_text,
                "Markdown",
                true,
                null,
                true,
                null
            );
            $func->update_user($from_id, "inviter", $text);
            $func->update_user($from_id, "status", "start");
            if ($info_user->verified !== "ok") {
                $telegram->SendMessage(
                    $from_id,
                    $enter_number_text,
                    "HTML",
                    true,
                    $enter_number_btn,
                    true,
                    null
                );
                $func->update_user($from_id, "status", "share_contact");
                exit();
            }
            $payment_link = json_decode(file_get_contents("https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/request_pay.php?u=$from_id&p=prime_" . $info_user->extra_info));
            if ($payment_link->ok == false) {
                $telegram->SendMessage(
                    $from_id,
                    $error_generate_payment_link_text,
                    "HTML",
                    true,
                    null,
                    true,
                    null
                );
                exit();
            }
            exit();
            $price = 0;
            switch ($info_user->extra_info) {
                case "eco":
                    $price = $eco_price * 10;
                    break;
                case "basic":
                    $price = $basic_price * 10;
                    break;
                case "business":
                    $price = $bussiness_price * 10;
                    break;
            }

            $payment_link_generated_text = str_replace("PRICE", number_format($price / 10, 0), $payment_link_generated_text);
            $payment_link_generated_text = str_replace("PAYMENT_LINK", $payment_link->link, $payment_link_generated_text);

            $telegram->SendMessage(
                $from_id,
                $payment_link_generated_text,
                "HTML",
                true,
                $btn_pay_buy_prime_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "start");
            exit();
        } else {
            $telegram->SendMessage(
                $from_id,
                $invalid_inviter_code_text,
                "Markdown",
                true,
                null,
                true,
                null
            );
        }
        break;

    case "share_contact":
        if (isset($update->message->contact->user_id) && $update->message->contact->user_id == $from_id) {
            $phone_number_share = $update->message->contact->phone_number;
            $start = substr($phone_number_share, 0, 3);
            if ($start == "+98" or $start == "989") {
                $inviter = $user->inviter;

                $func->update_user($from_id, "verified", "ok");
                $func->update_user($from_id, "number", $phone_number_share);
                $telegram->SendMessage($from_id, $verify_compelete_text, "HTML", true, null, true, null);
                $payment_link = json_decode(file_get_contents("https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/request_pay.php?u=$from_id&p=prime_" . $info_user->extra_info));
                if ($payment_link->ok == false) {
                    $telegram->SendMessage(
                        $from_id,
                        $error_generate_payment_link_text,
                        "HTML",
                        true,
                        null,
                        true,
                        null
                    );
                    exit();
                }
                $price = 0;
                switch ($info_user->extra_info) {
                    case "eco":
                        $price = $eco_price * 10;
                        break;
                    case "basic":
                        $price = $basic_price * 10;
                        break;
                    case "business":
                        $price = $bussiness_price * 10;
                        break;
                }

                $payment_link_generated_text = str_replace("PRICE", number_format($price / 10, 0), $payment_link_generated_text);
                $payment_link_generated_text = str_replace("PAYMENT_LINK", $payment_link->link, $payment_link_generated_text);
                $telegram->SendMessage(
                    $from_id,
                    $payment_link_generated_text,
                    "HTML",
                    true,
                    $btn_pay_buy_prime_btn,
                    true,
                    null
                );
                $func->update_user($from_id, "status", "start");
                exit();
            } else {
                $telegram->SendMessage(
                    $from_id,
                    $false_iranian_number_text,
                    "HTML",
                    true,
                    $enter_number_btn,
                    true,
                    null
                );
                exit();
            }
        } else {
            $telegram->SendMessage(
                $from_id,
                $please_share_with_btn_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact");
            exit();
        }
        break;

    case "share_contact2":
        if (isset($update->message->contact->user_id) && $update->message->contact->user_id == $from_id) {
            $phone_number_share = $update->message->contact->phone_number;
            $start = substr($phone_number_share, 0, 3);
            if ($start == "+98" or $start == "989") {

                $func->update_user($from_id, "verified", "ok");
                $func->update_user($from_id, "number", $phone_number_share);
                $telegram->SendMessage($from_id, $verify_compelete_text, "HTML", true, null, true, null);
                $telegram->SendMessage(
                    $from_id,
                    $enter_amount_charge_text,
                    "HTML",
                    true,
                    $enter_amount_charge_keyboard,
                    true,
                    null
                );

                $func->update_user($from_id, "status", "wallet_charge");
                exit();
            } else {
                $telegram->SendMessage(
                    $from_id,
                    $false_iranian_number_text,
                    "HTML",
                    true,
                    $enter_number_btn,
                    true,
                    null
                );
                exit();
            }
        } else {
            $telegram->SendMessage(
                $from_id,
                $please_share_with_btn_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact");
            exit();
        }
        break;

    case "share_contact3":
        if (isset($update->message->contact->user_id) && $update->message->contact->user_id == $from_id) {
            $phone_number_share = $update->message->contact->phone_number;
            $start = substr($phone_number_share, 0, 3);
            if ($start == "+98" or $start == "989") {

                $func->update_user($from_id, "verified", "ok");
                $func->update_user($from_id, "number", $phone_number_share);
                $telegram->SendMessage($from_id, $verify_compelete_text, "HTML", true, null, true, null);

                $user_info = $func->get_user($from_id);
                $free_order_can = 1 - (int)$user_info->free_order + floor((int)$user_info->free_order_invite);

                if ($free_order_can < 1) {
                    exit();
                }

                if ($user_info->free_order == 0) {
                    $func->update_user($from_id, "free_order", 1);
                } else {
                    $func->update_user($from_id, "free_order_invite", (double)$user_info->free_order_invite - (double)1);
                }
                $func->update_user($from_id, "status", "start");
                $link = $user_info->extra_info2;
                $file_info = $func->get_link_info($link);
                $site_info = [];
                if ($file_info["site"] == "freepik") {
                    $site_info = $func->get_group_order_price_by_id(1);
                } else {
                    $site_info = $func->get_group_order_price_by_id(2);
                }
                $file_codes = $file_info["file_code"] . "\n";
                $text_to_send = "تعداد 1 لینک از سایت " . $file_info["real_site"] . " ثبت شد.

فایل درخواستی : 
" . $file_codes . "
لینک دانلود بزودی برای شما ارسال خواهد شد";

                $msgid = $telegram->SendMessage(
                    $from_id,
                    $text_to_send,
                    "HTML",
                    true,
                    $start_btn,
                    true,
                    null
                )["result"]["message_id"];

                $preview_link = file_get_contents(
                    "https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/preview.php?url=" . $link
                );
                $preview_link = json_decode($preview_link, true);
                $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                $preview_type = "photo";

                if ($preview_link["result"] == true || is_array($preview_link)) {
                    $preview_type = $preview_link["type"];
                    $preview_photo = $preview_link["url"];
                }
                $insert_file = $func->add_file(
                    $link,
                    $from_id,
                    $msgid,
                    $from_id,
                    $preview_photo,
                    $preview_type
                );

                $func->update_file_info('file_code',$file_info["file_code"], $insert_file);
                $func->update_file_info('file_name',$file_info["file_name"], $insert_file);
                $func->update_file_info('count_order_info', 0, $insert_file);
                $check_exsist_file = $func->check_exsist_file($link);
                if (is_array($check_exsist_file) && $check_exsist_file[3] == "sent") {
                    $file_info = $func->get_file_compeleted_by_link($link)[0];
                    $func->update_file(
                        $file_info->link,
                        $file_info->type,
                        $file_info->file_id,
                        $file_info->caption,
                        $file_info->ext
                    );

                    $type = $file_info->type;
                    $text_send = $file_info->caption;
                    $file_id = $file_info->file_id;

                    if ($type == "text") {
                        $telegram->SendMessage(
                            $from_id,
                            $text_send,
                            "HTML",
                            true,
                            null,
                            true,
                            $msgid
                        );
                    } else {
                        $target_btn = [
                            "inline_keyboard" => [
                                [
                                    [
                                        "text" => "دریافت لینک دانلود مستقیم",
                                        "callback_data" => "Directlink_" . $insert_file
                                    ],
                                ],
                            ],
                        ];
                        $bb = $telegram->Send_file(
                            $type,
                            $file_id,
                            $from_id,
                            $msgid,
                            $text_send,
                            $target_btn,
                            "HTML"
                        );

                    }
                    $func->update_file_info('price', 0, $insert_file);
                    $func->update_file_info('status','sent', $insert_file);

                } else {

                    $auto_send_text = "";
                    if ($site_info->count_order_automatic_status == 1) {
                        $request_api = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step1.php?url=" . urlencode($link)), true);
                        if ($request_api["ok"] == true) {
                            $func->update_file_info('extra_info',json_encode($request_api["output"]), $insert_file);

                            $slug = $request_api["output"]["slug"];
                            $id = $request_api["output"]["id"];
                            $ispre = $request_api["output"]["ispre"];
                            $typee = $request_api["output"]["type"];

                            $request_api_complete = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step2.php?slug=$slug&id=$id&ispre=$ispre&type=$typee"), true);

                            while ($request_api_complete["ok"] !== true) {

                                $send = $telegram->SendMessage($chat_id, $request_api_complete["ok"], "HTML", true, null, true, $msgid);
                                if ($request_api_complete["response"]["title"] == "Have error when download") {
                                    $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود بوجود آمد ، شما میتوانید مجددا درخواست خود را ارسال کنید", "HTML", true, null, true, $msgid);
                                    $func->delete_file($link);
                                    $func->update_user($from_id, "free_order", 0);
                                    exit();
                                }
                                $request_api_complete = json_decode(file_get_contents("https://fileechbot.ir/fileech_prime/api_step2.php?slug=$slug&id=$id&ispre=$ispre&type=$typee"), true);

                            }
                            $download_link = $request_api_complete["link"];
                            $ext = $request_api_complete["ext"];
                            $func->update_file_info('download_link',$download_link, $insert_file);
                            $func->update_file_info('ext',$ext, $insert_file);
                            $auto_send_text .= "سفارش رایگان تست اتوماتیک api خارجی\nلینک دانلود : $download_link\n";
                        } else {
                            $send = $telegram->SendMessage($chat_id, "مشکلی در دریافت لینک دانلود بوجود آمد ، شما میتوانید مجددا درخواست خود را ارسال کنید", "HTML", true, null, true, $msgid);
                            $func->delete_file($link);
                            $func->update_user($from_id, "free_order", 0);
                            exit();
                        }
                    }

                    $btn_for_admin = [
                        "inline_keyboard" => [
                            [
                                [
                                    "text" => "ارسال فایل",
                                    "callback_data" =>
                                        "send_file_single:" .
                                        $insert_file .
                                        ":$from_id",
                                ],
                            ],
                        ],
                    ];
                    $get_order_single_text_admin = str_replace(
                        "USER",
                        "<a href=\"tg://user?id=$from_id\">$from_id</a>",
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "OPENCHAT",
                        "tg://openmessage?user_id=$from_id",
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "GROUP",
                        "❌",
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "LINK",
                        $link,
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "DATE",
                        jdate("Y/m/d H:i:s"),
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "REFID",
                        "s" . $insert_file,
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "FILECODE",
                        $file_info["file_code"],
                        $get_order_single_text_admin
                    );
                    $get_order_single_text_admin = str_replace(
                        "FILENAME",
                        $file_info["file_name"],
                        $get_order_single_text_admin
                    );
                    if ($preview_photo == "") {
                        $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                        $preview_type = "photo";
                        $func->update_file_info('preview', $preview_photo, $insert_file);
                        $func->update_file_info('preview_type',$preview_type, $insert_file);

                    }

                    $sended_manage = $telegram->Send_file(
                        $preview_type,
                        $preview_photo,
                        $checking_link,
                        null,
                        $auto_send_text . $get_order_single_text_admin,
                        $btn_for_admin,
                        "HTML"
                    );


                    if ($sended_manage["ok"] !== true) {

                        $preview_photo = "AgACAgQAAxkBAAJZgWLfubhJzt9ss4MhwDzbsU5a34PwAALorTEbSftdU4HnR5YORCE6AQADAgADeAADKQQ";
                        $preview_type = "photo";
                        $sended_manage = $telegram->Send_file(
                            $preview_type,
                            $preview_photo,
                            $checking_link,
                            null,
                            $auto_send_text . $get_order_single_text_admin,
                            $btn_for_admin,
                            "HTML"
                        );

                        $func->update_file_info('msg_mng', $sended_manage["result"]["message_id"], $insert_file);
                        $func->update_file_info('preview', $preview_photo, $insert_file);
                        $func->update_file_info('preview_type',$preview_type, $insert_file);
                    } else {

                        $func->update_file_info('msg_mng', $sended_manage["result"]["message_id"], $insert_file);
                    }
                    if ($site_info->count_order_automatic_status == 1) {
                        $send2 = $telegram->SendMessage(
                            $checking_link,
                            "Downloading ...",
                            "HTML",
                            true,
                            null,
                            true,
                            $sended_manage["result"]["message_id"]
                        );

                        $func->update_file_info('status_msgid', $send2["result"]["message_id"], $insert_file);

                        $func->update_file_info('status', 'sending', $insert_file);
                        $file_link = $func->get_file_by_id((int)$insert_file)[0];
                        if ($file_link->chat_id == $file_link->user_id) {
                            $request_price = $file_link->price;
                            $open_order_count = $func->get_files_open_by_chat_id($file_link->chat_id);
                            $message = "
📍سفارش های باز/تکمیل نشده: ($open_order_count / 10) 

💵هزینه سفارش : " . number_format($request_price) . " تومان
📁کد فایل : " . $file_link->file_code . "
#️⃣کد پیگیری : " . $file_link->id . "

⚙️وضعیت:  سفارش ثبت شد

👨🏻‍💻پشتیبانی: @FileechAdmin
";
                            $s = $telegram->Send_file(
                                $file_link->preview_type,
                                $file_link->preview,
                                $file_link->chat_id,
                                $file_link->msg_id,
                                $message,
                                null,
                                "HTML"
                            );

                            $func->update_file_info('msg_id', $s["result"]["message_id"], $file_link->id);
                        }
                        //shell_exec ('nohup python3 /home/fileechbot/public_html/fileech_prime/python/fileecher2.py ' . $insert_file . ' > /dev/null 2>/dev/null &');
                        if ($func->get_meta_data("send_order_way") == "py") {
                            shell_exec('nohup python3 /home/fileechbot/public_html/fileech_prime/python/fileecher2.py ' . $insert_file . ' > /dev/null 2>/dev/null &');
                        } else {
                            file_get_contents("https://fileechbot.ir/file_uploader/index.php?id=" . $insert_file);
                        }
                        sleep(30);

                    }
                }

                $func->update_user($from_id, "status", "start");
                exit();
            } else {
                $telegram->SendMessage(
                    $from_id,
                    $false_iranian_number_text,
                    "HTML",
                    true,
                    $enter_number_btn,
                    true,
                    null
                );
                exit();
            }
        } else {
            $telegram->SendMessage(
                $from_id,
                $please_share_with_btn_text,
                "HTML",
                true,
                $enter_number_btn,
                true,
                null
            );
            $func->update_user($from_id, "status", "share_contact3");
            exit();
        }
        break;
    case "wallet_charge":
        $text = str_replace(",", "", $text);
        if (is_numeric($text)) {
            if ($text >= 10000 && $text <= 50000000) {
                $payment_link = json_decode(file_get_contents("https://" . $_SERVER["SERVER_NAME"] . "/fileech_prime/request_pay.php?u=$from_id&p=wallet_charge&a=" . $text));
                if ($payment_link->ok == false) {
                    $telegram->SendMessage(
                        $from_id,
                        $error_generate_payment_link_text,
                        "HTML",
                        true,
                        null,
                        true,
                        null
                    );
                    exit();
                }

                $payment_link_generated_text = str_replace("PRICE", number_format($text, 0), $payment_link_generated_text);
                $payment_link_generated_text = str_replace("PAYMENT_LINK", $payment_link->link, $payment_link_generated_text);
                $telegram->SendMessage(
                    $from_id,
                    $payment_link_generated_text,
                    "HTML",
                    true,
                    $btn_back_to_main_menu_btn,
                    true,
                    null
                );
                $func->update_user($from_id, "status", "start");
                exit();
            } else {
                $telegram->SendMessage(
                    $from_id,
                    $enter_valid_amount_charge_text,
                    "HTML",
                    true,
                    $enter_amount_charge_keyboard,
                    true,
                    null
                );
                exit();
            }
        } else {
            $telegram->SendMessage(
                $from_id,
                $enter_numeric_amount_charge_text,
                "HTML",
                true,
                $enter_amount_charge_keyboard,
                true,
                null
            );
            exit();

        }
        break;

}

if (strpos($text, "payments") !== false) {
    $info = explode("-", $text);
    $get_payments = $func->Get_UserPayments($from_id, $info[1]);
    if ($get_payments !== false) {
        $telegram->DeleteMessage($from_id, $msgid);
        $text_to_send = $get_payments[1];
        $btn_to_send = ["inline_keyboard" => $get_payments[0]];
        $telegram->SendMessage(
            $from_id,
            $text_to_send,
            "HTML",
            true,
            $btn_to_send,
            true,
            null
        );
    } else {
        $telegram->answerCallbackQuery($update->callback_query->id, "نتیجه ای برای نمایش یافت نشد", false);
        exit();
    }
}

if (strpos($text, "files") !== false) {
    if ($func->get_user($from_id)->status !== "s2a2" && $func->get_user($from_id)->status !== "s2a2_gp") {
        $info = explode("-", $text);
        if ($info[0] == "files") {
            $get_files = $func->Get_UserFiles($from_id, (int)$info[1]);
            if ($get_files !== false) {
                $telegram->DeleteMessage($from_id, $msgid);
                $text_to_send = $get_files[1];
                $btn_to_send = ["inline_keyboard" => $get_files[0]];
                $telegram->SendMessage(
                    $from_id,
                    $text_to_send,
                    "HTML",
                    true,
                    $btn_to_send,
                    true,
                    null
                );

            } else {
                $telegram->answerCallbackQuery($update->callback_query->id, "نتیجه ای برای نمایش یافت نشد", false);
                exit();
            }
        }
    }
}

if (strpos($text, "_") !== false) {
    $data = explode("_", $text);
    if (count($data) > 1) {

        if ($data[0] == "/dl") {
            $file_info = $func->get_file_by_id_and_user($data[1], $from_id);
            if ($file_info !== false) {
                $telegram->Send_file(
                    $file_info->type,
                    $file_info->file_id,
                    $from_id,
                    null,
                    null,
                    null,
                    "HTML"
                );
            }
        }
        if ($data[0] == "Directlink") {

            $func->update_file_info('dl_msg', $msgid, $data[1]);
            shell_exec('nohup python3 /home/fileechbot/public_html/fileech_prime/python/ftp.py ' . $data[1] . ' > /dev/null 2>/dev/null &');

            $telegram->answerCallbackQuery(
                $update->callback_query->id,
                "لینک دانلود به زودی برای شما ارسال خواهد شد",
                false
            );

            $target_btn = [
                "inline_keyboard" => [
                    [
                        [
                             "text" => "کد سفارش را برای پشتیبانی ارسال کنید",
                            "callback_data" => "----",
                        ],
                    ],
                ],
            ];
            $telegram->editMessageReplyMarkup(
                $chat_id,
                $msgid,
                $target_btn
            );
            exit();
        }
    }
}
?>
