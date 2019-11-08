<?php
// This config file enables IDE helper to understand json type column
// introduced from MySQL 5.7.
return [
    'custom_db_types' => [
        'mysql'=> [
            'json'=>'json_array',
        ]
    ],
];
