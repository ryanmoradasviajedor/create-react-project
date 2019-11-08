<?php

use \Phan\Issue;

return [
    'target_php_version' => '7.0',

    // Source directories to analyze
    // Dependencies of the analysis target should be included for accurate analysis.
    'directory_list' => [
        '.phan/stabs',
        'modules',
//        'vendor', // This could make the analysis more accurate, but very slow.
        'vendor/laravel',
        'vendor/october',
        'plugins/lovata',
        'plugins/goodbet/custom',
        'plugins/spycetek/utility',
        'plugins/spycetek/customordersshopaholic',
        'plugins/spycetek/extensionsshopaholic',
        'plugins/spycetek/gmopgshopaholic',
        'plugins/spycetek/protectionshopaholic',
        'plugins/spycetek/frontendlogger',
    ],

    // Source directories to exclude from analysis target
    // Among those in 'directory_list' above, list directories that you don't want to analyze as target.
    "exclude_analysis_directory_list" => [
        '.phan',
        'modules',
        'vendor',
        'plugins/lovata',
        'plugins/goodbet/custom',
//        'plugins/spycetek/utility',
//        'plugins/spycetek/customordersshopaholic',
//        'plugins/spycetek/extensionsshopaholic',
//        'plugins/spycetek/gmopgshopaholic',
//        'plugins/spycetek/protectionshopaholic',
//        'plugins/spycetek/frontendlogger',
    ],
    'exclude_file_regex' => '@plugins/.*/.*/assets@',

//    'minimum_severity' => Issue::SEVERITY_NORMAL,
    'minimum_severity' => Issue::SEVERITY_LOW, // most strict
//    'suppress_issue_types' => [
//        'PhanTypeInvalidThrowsNonThrowable',
//        // Somehow -i option not working anymore
//        'PhanUndeclaredFunction',
//        'PhanUndeclaredMethod',
//        'PhanUndeclaredExtendedClass',
//        'PhanUndeclaredTrait',
//        'PhanUndeclaredConstant',
//        'PhanUndeclaredProperty',
//        'PhanUndeclaredStaticMethod',
//        'PhanUndeclaredClass',
//        'PhanUndeclaredClassConstant',
//        'PhanUndeclaredClassMethod',
//        'PhanUndeclaredClassProperty',
//        'PhanUndeclaredClassCatch',
//        'PhanUndeclaredTypeParameter',
//        'PhanUndeclaredTypeProperty',
//        'PhanUndeclaredTypeReturnType',
//        'PhanUndeclaredTypeThrowsType',
//        'PhanUndeclaredClassCatch',
//    ],
];
