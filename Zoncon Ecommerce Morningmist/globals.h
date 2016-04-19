//
//  constants.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 30/10/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef globals_h
#define globals_h


static NSString *PID = @"14";
#define TEXT_COLOR [UIColor darkGrayColor]
#define TILE_COLOR [UIColor whiteColor]
static NSString *DB_FILENAME = @"zoncon_ecommerce.db";
static NSString *SHARE_MSG = @"ZonCon ECommerce Morningmist App";
static NSString *SHARE_SUBJECT = @"ZonCon E-Commerce Morningmist App";
static NSString *SHARE_CONTENT = @"Thank you for downoading the ZonCon E-Commerce App!";
static NSString *FEEDBACK_EMAIL_SUBJECT = @"ZonCon E-Commerce Morningmist App Feedback";
static NSString *FEEDBACK_EMAIL_ABS = @"youremail@yourdomain.com";
static NSString *APPSTORE_LINK = @"http://appstore.com/<your-app-name>";

static NSString *FEEDBACK_EMAIL_MEGO = @"megotechnologies@gmail.com";

static NSString *SERVER = @"https://www.zoncon.com/v6_1/";
static NSString *API = @"index.php/projects/";
static NSString *UPLOADS = @"uploads/";
static NSString *API_STREAMS = @"get_public_streams";
static NSString *API_INDI_STREAMS = @"get_public_individual_stream";
static NSString *API_NOTIFICATIONS = @"get_public_notification";
static NSString *API_COUNTRIES = @"get_public_countries";
static NSString *API_STATES = @"get_public_states";
static NSString *API_CITIES = @"get_public_cities";
static NSString *API_CART = @"get_public_cart";
static NSString *API_USER_APPS = @"get_public_user_apps";
static NSString *API_CREATE_ACCOUNT = @"add_public_consumer";
static NSString *API_RESET_PASSWORD = @"public_consumer_password_reset";
static NSString *API_FORGOT_CHANGE_PASSWORD = @"public_consumer_forgot_change_password";
static NSString *API_CHANGE_PASSWORD = @"public_consumer_change_password";
static NSString *API_LOGIN = @"public_consumer_login";
static NSString *API_ORDER_NEW = @"public_new_order";
static NSString *API_ORDER_CONFIRM = @"public_confirm_order_payment";
static NSString *API_ORDER_CANCEL = @"public_cancel_order_payment";
static NSString *API_VALIDATE_LOC = @"public_validate_location";
static NSString *API_VERIFY_LOGIN = @"public_verify_login";
static NSString *API_ORDERS_LIST = @"public_orders_get";
static NSString *API_COUPON_VALIDATE = @"public_coupon_validate";
static NSString *API_ORDERS_SINGLE = @"public_orders_get_single";
static NSString *API_GET_ITEM_LIKES = @"get_public_item_likes";
static NSString *API_ADD_ITEM_LIKE = @"add_public_item_like";
static NSString *API_GET_STREAM_LIKES = @"get_public_stream_likes";
static NSString *API_ADD_STREAM_LIKE = @"add_public_stream_like";
static NSString *API_GET_STREAM_VIEWS = @"get_public_stream_views";
static NSString *API_GET_STREAM_SHARES = @"get_public_stream_shares";
static NSString *API_GET_ITEM_VIEWS = @"get_public_item_views";
static NSString *API_GET_ITEM_SHARES = @"get_public_item_shares";
static NSString *API_SYNC_ANALYTICS = @"sync_public_analytics";
static NSString *API_REGISTER_TOKEN = @"public_register_token";
static NSString *PG_IFRAME_URL = @"";
static NSString *PG_REDIRECT_URL = @"";
static NSString *PG_MERCHANT_ID = @"";

static NSString *MAPS_PREFIX = @"https://maps.google.com/?q=";

static NSString *DB_CURR_TABLENAME = @"dbtablepng11";
static NSString *DB_OLD_TABLENAME = @"dbtablepng10";

static NSString *DB_COL_ID = @"_id";
static NSString *DB_COL_SRV_ID = @"idServer";
static NSString *DB_COL_TYPE = @"type";
static NSString *DB_COL_TITLE = @"title";
static NSString *DB_COL_SUBTITLE = @"subtitle";
static NSString *DB_COL_CONTENT = @"content";
static NSString *DB_COL_TIMESTAMP = @"timestamp";
static NSString *DB_COL_STOCK = @"stock";
static NSString *DB_COL_PRICE = @"price";
static NSString *DB_COL_EXTRA_1 = @"extra1";
static NSString *DB_COL_EXTRA_2 = @"extra2";
static NSString *DB_COL_EXTRA_3 = @"extra3";
static NSString *DB_COL_EXTRA_4 = @"extra4";
static NSString *DB_COL_EXTRA_5 = @"extra5";
static NSString *DB_COL_EXTRA_6 = @"extra6";
static NSString *DB_COL_EXTRA_7 = @"extra7";
static NSString *DB_COL_EXTRA_8 = @"extra8";
static NSString *DB_COL_EXTRA_9 = @"extra9";
static NSString *DB_COL_EXTRA_10 = @"extra10";
static NSString *DB_COL_WEIGHT = @"weight";
static NSString *DB_COL_BOOKING = @"bookingPrice";
static NSString *DB_COL_DISCOUNT = @"discount";
static NSString *DB_COL_SKU = @"sku";
static NSString *DB_COL_SIZE = @"size";
static NSString *DB_COL_EXTRA_WEIGHT = @"weightExtra";
static NSString *DB_COL_NAME = @"name";
static NSString *DB_COL_CAPTION = @"caption";
static NSString *DB_COL_URL = @"url";
static NSString *DB_COL_LOCATION = @"location";
static NSString *DB_COL_EMAIL = @"email";
static NSString *DB_COL_PHONE = @"phone";
static NSString *DB_COL_PATH_ORIG = @"path_orig";
static NSString *DB_COL_PATH_PROC = @"path_proc";
static NSString *DB_COL_PATH_TH = @"path_th";
static NSString *DB_COL_CART_ITEM_STREAM_ID = @"cart_item_stream_id";
static NSString *DB_COL_CART_ITEM_ITEM_ID = @"cart_item_item_id";
static NSString *DB_COL_CART_ITEM_QUANTITY = @"cart_item_quantity";
static NSString *DB_COL_CART_COUPON_CODE = @"cart_coupon_code";
static NSString *DB_COL_CART_ISOPEN = @"cart_isopen";
static NSString *DB_COL_BRANCHINBOXSTREAM_ID = @"branchinboxstream_id";
static NSString *DB_COL_BRANCHINBOXITEM_ID = @"branchinboxitem_id";
static NSString *DB_COL_BRANCHSTREAM_ID = @"branchstream_id";
static NSString *DB_COL_BRANCHITEM_ID = @"branchitem_id";
static NSString *DB_COL_MEMBERINBOXSTREAM_ID = @"memberinboxstream_id";
static NSString *DB_COL_MEMBERINBOXITEM_ID = @"memberinboxitem_id";
static NSString *DB_COL_FOREIGN_KEY = @"foreign_key";
static NSString *DB_COL_STREAM_ID = @"memberstream_id";
static NSString *DB_COL_ITEM_ID = @"item_id";

static NSString *SYMBOL_RUPEE = @"INR";

static NSString *DB_RECORD_TYPE_STREAM = @"RECORD_STREAM";
static NSString *DB_RECORD_TYPE_ITEM = @"RECORD_ITEM";
static NSString *DB_RECORD_TYPE_PICTURE = @"RECORD_PICTURE";
static NSString *DB_RECORD_TYPE_ATTACHMENT = @"RECORD_ATTACHMENT";
static NSString *DB_RECORD_TYPE_URL = @"RECORD_URL";
static NSString *DB_RECORD_TYPE_LOCATION = @"RECORD_LOCATION";
static NSString *DB_RECORD_TYPE_CONTACT = @"RECORD_CONTACT";
static NSString *DB_RECORD_TYPE_CART = @"RECORD_CART";
static NSString *DB_RECORD_TYPE_CART_ITEM = @"RECORD_CART_ITEM";
static NSString *DB_RECORD_TYPE_SELFIE = @"RECORD_SELFIE";
static NSString *DB_RECORD_TYPE_LOCATION_COUNTRY = @"RECORD_LOCATION_COUNTRY";
static NSString *DB_RECORD_TYPE_LOCATION_STATE = @"RECORD_LOCATION_STATE";
static NSString *DB_RECORD_TYPE_LOCATION_CITY = @"RECORD_LOCATION_CITY";
static NSString *DB_RECORD_TYPE_BRANCHSTREAM = @"RECORD_BRANCHSTREAM";
static NSString *DB_RECORD_TYPE_BRANCHITEM = @"RECORD_BRANCHITEM";
static NSString *DB_RECORD_TYPE_PRICE_COUNTRYWISE = @"RECORD_PRICE_COUNTRYWISE";
static NSString *DB_RECORD_TYPE_PRICE_STATEWISE = @"RECORD_PRICE_STATEWISE";
static NSString *DB_RECORD_TYPE_PRICE_CITYWISE = @"RECORD_PRICE_CITYWISE";
static NSString *DB_RECORD_TYPE_MY_COUNTRY = @"RECORD_MY_COUNTRY";
static NSString *DB_RECORD_TYPE_MY_STATE = @"RECORD_MY_STATE";
static NSString *DB_RECORD_TYPE_MY_CITY = @"RECORD_MY_CITY";
static NSString *DB_RECORD_TYPE_MY_PHONE = @"RECORD_MY_PHONE";
static NSString *DB_RECORD_TYPE_MY_EMAIL = @"RECORD_MY_EMAIL";
static NSString *DB_RECORD_TYPE_MY_TOKEN = @"RECORD_MY_TOKEN";
static NSString *DB_RECORD_TYPE_MY_NAME = @"RECORD_MY_NAME";
static NSString *DB_RECORD_TYPE_MY_ADDRESS = @"RECORD_MY_ADDRESS";
static NSString *DB_RECORD_TYPE_MY_PINCODE = @"RECORD_MY_PINCODE";
static NSString *DB_RECORD_TYPE_STREAM_VIEWS = @"RECORD_STREAM_VIEWS";
static NSString *DB_RECORD_TYPE_ITEM_VIEWS = @"RECORD_ITEM_VIEWS";
static NSString *DB_RECORD_TYPE_ITEM_SHARES = @"RECORD_ITEM_SHARES";
static NSString *DB_RECORD_TYPE_NOTIF = @"RECORD_NOTIF";
static NSString *DB_RECORD_TYPE_FIRSTTIME = @"RECORD_FIRSTTIME";
static NSString *DB_RECORD_TYPE_DISCOUNT = @"RECORD_DISCOUNT";
static NSString *DB_RECORD_TYPE_COUPON = @"RECORD_COUPON";
static NSString *DB_RECORD_TYPE_TAX_1 = @"RECORD_TAX_1";
static NSString *DB_RECORD_TYPE_TAX_2 = @"RECORD_TAX_2";
static NSString *DB_RECORD_TYPE_ALLOW_NOTIFICATIONS = @"ALLOW_NOTIFICATIONS";
static NSString *DB_RECORD_TYPE_MESSAGESTREAM_NOTIFICATION_ALERT = @"MESSAGE_NOTIF_ALERT";
static NSString *DB_RECORD_TYPE_NOTIFICATIONSTREAM_NOTIFICATION_ALERT = @"NOTIFICATION_NOTIF_ALERT";
static NSString *DB_RECORD_TYPE_MEMBERINBOXMESSAGE_NOTIFICATION_ALERT = @"MEMBERINBOXMESSAGE_NOTIF_ALERT";
static NSString *DB_RECORD_TYPE_BRANCHINBOXMESSAGE_NOTIFICATION_ALERT = @"BRANCHINBOXMESSAGE_NOTIF_ALERT";
static NSString *DB_RECORD_TYPE_MESSAGESTREAM_PUSH_ALERT = @"MESSAGE_PUSH_ALERT";
static NSString *DB_RECORD_TYPE_NOTIFICATIONSTREAM_PUSH_ALERT = @"NOTIFICATION_PUSH_ALERT";
static NSString *DB_RECORD_TYPE_MEMBERINBOXMESSAGE_PUSH_ALERT = @"MEMBERINBOXMESSAGE_PUSH_ALERT";
static NSString *DB_RECORD_TYPE_BRANCHINBOXMESSAGE_PUSH_ALERT = @"BRANCHINBOXMESSAGE_PUSH_ALERT";
static NSString *DB_RECORD_VALUE_CART_OPEN = @"yes";
static NSString *DB_RECORD_VALUE_CART_CLOSED = @"no";
static NSString *DB_DISCOUNT_TYPE_FLAT = @"FLAT";
static NSString *DB_DISCOUNT_TYPE_PERCENTAGE = @"PERCENTAGE";

static NSString *ORDER_PROCESSING = @"PROCESSING";
static NSString *ORDER_CANCELLED = @"CANCELLED";
static NSString *ORDER_COMPLETE = @"COMPLETE";

static int MAX_CART_QUANTITY = 100;

static NSString *LOAD_MORE_CAPTION = @"LOAD MORE";
static NSString *LOAD_MORE_CAPTION_LOADING = @"Loading...";
static NSString *LOAD_MORE_CAPTION_END = @"REACHED THE END";

static NSString *DB_STREAM_TYPE_PRODUCT = @"PRODUCT";
static NSString *DB_STREAM_TYPE_MESSAGE = @"MESSAGE";
static NSString *DB_STREAM_TYPE_NOTIFICATION = @"NOTIFICATION";
static NSString *DB_STREAM_TYPE_BRANCH = @"BRANCH";
static NSString *DB_STREAM_TYPE_MEMBERSHIPTYPE = @"MEMBERSHIPTYPE";
static NSString *DB_STREAM_TYPE_MEMBERINBOX = @"MEMBERINBOX";
static NSString *DB_STREAM_TYPE_BRANCHINBOX = @"BRANCHINBOX";
static NSString *DB_STREAM_TYPE_BRANCHINBOXMESSAGE = @"BRANCHINBOXMESSAGE";
static NSString *DB_STREAM_TYPE_MEMBERINBOXMESSAGE = @"MEMBERINBOXMESSAGE";
static NSString *DB_STREAM_TYPE_MYMEMBERSHIP = @"MYMEMBERSHIP";

static NSString *RESULT_SUCCES = @"success";

static int TABLE_LOADED_TAG = 99;
static int LIST_CELL_HEIGHT = 100;

static int FONT_SIZE_NAVBAR_TITLES = 20;
static int FONT_SIZE_DESIGNS_TITLES = 20;
static int FONT_SIZE_LIST_TITLES = 18;
static int FONT_SIZE_LIST_DESCS = 16;
static int FONT_SIZE_LIST_LOADMORE = 18;
static int FONT_SIZE_DETAIL_TITLE = 18;
static int FONT_SIZE_DETAIL_DESC = 17;
static int FONT_SIZE_DETAIL_CONTENT = 16;
static int FONT_SIZE_ACTION_BUTTON = 12;


#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#endif
