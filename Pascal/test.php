<?php

class InstanceOfTest
{
    static private ?self $instance = null;
    public function __construct()
    {
    }

    public static function getInstance(): self
    {
        if (!isset(self::$instance)) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function __clone() {}

    public function __wakeup() 
    {
        throw new \Exception("Cannot unserialize a singleton.");
    }
}

$instance1 = InstanceOfTest::getInstance();