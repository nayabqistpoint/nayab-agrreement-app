lib/
│
├── main.dart                                   <-- صرف ایپ کا آغاز (Initialization)
│
└── agreement_generator/                        <-- مرکزی فیچر فولڈر
    │
    ├── agreement_page.dart                     <-- مین سکرین (صرف کارڈز جوڑے گی)
    ├── agreement_controller.dart               <-- سارا ڈیٹا، لاجک اور کنٹرولرز
    │
    ├── services/                               <-- تمام سروسز فولڈر
    │   ├── qr_scanner_service.dart             <-- کیمرہ اور QR ریڈنگ
    │   ├── template_service.dart               <-- ٹیکسٹ ٹیگز اور تجزیہ
    │   └── pdf_service.dart                    <-- جمیل نوری فونٹ پی ڈی ایف اور پرنٹ
    │
    └── components/                             <-- تمام UI کارڈز اور وجٹس
        ├── qr_scanner_card_ui.dart             <-- QR سکین کا اوپر والا کارڈ
        ├── template_selector_card_ui.dart      <-- ڈراپ ڈاؤن اور کسٹم ٹیکسٹ کارڈ
        ├── agreement_fields_card_ui.dart       <-- تمام ان پٹ ڈبوں کا کارڈ
        └── action_buttons_ui.dart              <-- پرنٹ اور ری سیٹ کے بٹن