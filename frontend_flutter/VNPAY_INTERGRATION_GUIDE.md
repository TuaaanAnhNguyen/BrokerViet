# VNPAY Integration Guide
## Flutter + Supabase Architecture

---

# Goal

Integrate VNPAY payment gateway into a Flutter application while using Supabase as the backend.

The merchant credentials already exist inside environment variables.

The implementation MUST NEVER expose the merchant secret or checksum key to Flutter.

---

# Architecture

```
Flutter App
      │
      │ HTTPS
      ▼
Supabase Edge Function
      │
      │ Build signed payment URL
      ▼
VNPAY Gateway
      │
      ├────────────► Return URL (Deep Link)
      │
      └────────────► IPN URL (Supabase Edge Function)
```

Responsibilities:

Flutter

- Login
- Booking creation
- Call payment API
- Open VNPAY
- Receive Deep Link
- Query payment result

Supabase

- Create payment URL
- Generate checksum
- Verify checksum
- Handle IPN
- Update database
- Prevent duplicate processing

VNPAY

- Payment UI
- Bank processing
- Redirect customer
- Notify merchant through IPN

---

# Environment Variables

Store inside Supabase secrets.

```
VNP_TMN_CODE=
VNP_HASH_SECRET=
VNP_PAYMENT_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
VNP_RETURN_URL=myapp://payment-result
VNP_IPN_URL=https://<project>.supabase.co/functions/v1/vnpay-ipn
```

Flutter only knows

- payment endpoint
- return deep link

Flutter NEVER knows

- Hash Secret
- Merchant credentials

---

# Database

Suggested payment table

```
payments

id
booking_id
user_id

txn_ref
amount

status

vnp_transaction_no
vnp_bank_code

response_code

created_at
updated_at
paid_at
```

Status

```
pending

processing

paid

failed

cancelled
```

---

# Payment Flow

## Step 1

Flutter creates booking.

Booking is inserted as

```
pending
```

---

## Step 2

Flutter calls

```
POST
/functions/v1/create-vnpay-payment
```

Body

```
booking_id
amount
order_info
```

---

## Step 3

Edge Function

Validate booking.

Generate

```
vnp_TxnRef
```

Generate

```
vnp_CreateDate
```

Generate

```
vnp_ExpireDate
```

Construct parameters.

Sort parameters alphabetically.

Generate HMAC SHA512 checksum.

Append

```
vnp_SecureHash
```

Return

```
payment_url
```

Official documentation requires the checksum to be generated after sorting all VNPAY parameters alphabetically and signing them using HMAC SHA512 with the merchant secret. :contentReference[oaicite:1]{index=1}

---

# Required Parameters

Always include

```
vnp_Version = 2.1.0

vnp_Command = pay

vnp_TmnCode

vnp_Amount

vnp_CreateDate

vnp_CurrCode

vnp_IpAddr

vnp_Locale

vnp_OrderInfo

vnp_OrderType

vnp_ReturnUrl

vnp_TxnRef

vnp_ExpireDate
```

Optional

```
vnp_BankCode
```

---

# Amount

VNPAY expects

```
amount × 100
```

Example

```
100,000 VND

becomes

10000000
```

Never send decimal separators.

---

# Transaction Reference

Use a globally unique reference.

Recommended

```
bookingId_timestamp_random
```

Example

```
BK123_1751239912
```

Must never duplicate during the same day.

---

# Flutter

Open payment URL using

```
url_launcher
```

or

```
flutter_custom_tabs
```

Do NOT use a WebView.

VNPAY expects the user's banking applications to work correctly.

---

# Return URL

Configure deep linking

Android

```
myapp://payment-result
```

iOS

```
myapp://payment-result
```

When redirected

Flutter receives

```
myapp://payment-result?
vnp_ResponseCode=00
...
```

Do NOT trust these values.

Only use them to display a loading screen.

Immediately call

```
GET payment status
```

from Supabase.

The official documentation specifies that the Return URL should only verify checksum and display information to the customer. It should not update payment state. :contentReference[oaicite:2]{index=2}

---

# IPN

This is the most important endpoint.

```
POST

/functions/v1/vnpay-ipn
```

Workflow

Receive parameters

↓

Extract

```
vnp_SecureHash
```

↓

Remove checksum

↓

Sort parameters

↓

Generate checksum

↓

Compare

↓

Reject if invalid

↓

Find payment

↓

Verify amount

↓

Verify payment not processed

↓

Update database

↓

Return JSON

```
{
  "RspCode":"00",
  "Message":"Confirm Success"
}
```

The official VNPAY documentation recommends:

- verify checksum first
- verify order exists
- verify amount
- ensure payment has not already been processed
- then update the database
- finally return the appropriate RspCode to VNPAY. :contentReference[oaicite:3]{index=3}

---

# Payment Success

Only mark payment

```
paid
```

when

```
vnp_ResponseCode == "00"

AND

vnp_TransactionStatus == "00"
```

Anything else

```
failed
```

---

# Security Rules

Never

❌ Generate checksum in Flutter

Never

❌ Store merchant secret in app

Never

❌ Trust Return URL

Never

❌ Update payment from Flutter

Never

❌ Trust client amount

Always

✔ Verify checksum

✔ Verify amount

✔ Verify transaction status

✔ Verify payment uniqueness

✔ Update database only from IPN

---

# Recommended Edge Functions

## create-vnpay-payment

Input

```
booking_id
```

Output

```
payment_url
txn_ref
```

Responsibilities

- Validate booking
- Generate payment URL
- Save txn_ref

---

## vnpay-ipn

Input

VNPAY callback

Responsibilities

- Verify checksum
- Verify amount
- Update payment
- Return RspCode

---

## get-payment-status

Input

```
booking_id
```

Output

```
pending

processing

paid

failed
```

Flutter calls this after returning from VNPAY.

---

# Flutter Screens

Booking

↓

Review

↓

Create Payment

↓

Open Browser

↓

VNPAY

↓

Deep Link

↓

Loading Screen

↓

Query Payment Status

↓

Success

or

Failure

---

# Recommended Packages

```
supabase_flutter

flutter_dotenv

url_launcher

app_links

uuid

intl

crypto
```

crypto is only required if checksum generation is ever tested locally.

Production checksum generation belongs only inside Supabase.

---

# Deep Link Example

AndroidManifest

```
<intent-filter>

<action android:name="android.intent.action.VIEW"/>

<category android:name="android.intent.category.DEFAULT"/>

<category android:name="android.intent.category.BROWSABLE"/>

<data
    android:scheme="myapp"
    android:host="payment-result"/>

</intent-filter>
```

---

# Payment State Machine

```
pending
    │
    ▼
redirected
    │
    ▼
waiting_ipn
    │
 ┌──┴────┐
 │        │
 ▼        ▼
paid    failed
```

Flutter should never transition states.

Only Supabase does.

---

# Retry Handling

VNPAY retries IPN when merchant responses indicate failure or timeout.

Therefore

The IPN endpoint must be idempotent.

If

```
status == paid
```

Simply return

```
RspCode=02
```

or another response specified by VNPAY indicating the payment has already been processed.

Never process the same payment twice.

---

# Recommended Folder Structure

Flutter

```
lib/

 payment/

    payment_service.dart

    payment_repository.dart

    payment_page.dart

    payment_result_page.dart
```

Supabase

```
supabase/

 functions/

    create-vnpay-payment/

    vnpay-ipn/

    get-payment-status/
```

---

# Final Notes

The implementation should follow these principles:

- Merchant secret exists only in Supabase.
- Flutter never signs requests.
- IPN is the only source of truth for payment completion.
- Return URL is used only for user navigation.
- All payment updates are idempotent.
- Every callback verifies checksum before any database operation.
- Payment status is queried from Supabase after the app is reopened through the deep link.

This architecture aligns with the VNPAY PAY integration model while adapting it to a modern Flutter + Supabase stack.