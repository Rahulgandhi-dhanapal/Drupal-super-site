<?php
/**
 * @file
 * Enables modules and site configuration for a standard site installation.
 */

// Add any custom code here like hook implementations.

use Drupal\user\Entity\User;
use Drupal\user\UserInterface;
use Drupal\Core\Messenger\MessengerInterface;

/**
 * Implements hook_install_tasks().
 */
function supersite_profile_install_tasks($install_state) {
  $tasks = [
    'supersite_profile_setup_cleanup' => [
      'display_name' => t('Cleanup'),
      'display' => FALSE,
      'type' => 'normal',
    ],
    'supersite_profile_setup_translations' => [
      'display_name' => t('Translations import'),
      'type' => 'batch',
    ],
  ];
  return $tasks;
}

/**
 * Post profile install function
 */
function supersite_profile_setup_cleanup() {
  $email = 'innowin82@gmail.com';
  //only set system site settings on initial install if a sync config exists.
  if (!file_exists(DRUPAL_ROOT . '/profiles/supersite_profile/config/sync/system.site.yml')) {
    \Drupal::configFactory()->getEditable('system.site')
      ->set('page.front', '/node')
      ->set('mail', $email)
      ->set('name', 'supersite')
      ->save(TRUE);
  }
  // set user-name and email for user 1.
  $user = User::load(1);
  $user->set('name', 'innowin-admin');
  $user->set('mail', $email);
  $user->save();
  \Drupal::messenger()->addMessage(t('User 1 rename to innowin-admin'));

  //only allow adminstrators create accounts
  $user_settings = \Drupal::configFactory()->getEditable('user.settings');
  $user_settings->set('register', UserInterface::REGISTER_ADMINISTRATORS_ONLY)->save(TRUE);
  // Enable the admin theme
  \Drupal::configFactory()->getEditable('node.settings')->set('use_admin_theme', TRUE)->save(TRUE);
}

/**
 * Installation task to import translation
 */
function supersite_profile_setup_translations() {
  $moduleHandler = \Drupal::service('module_handler');
  if (!$moduleHandler->moduleExists('locale')) {
    return;
  }
  $options = _locale_translation_default_update_options();
  $batch = locale_translation_batch_update_build(['supersite_profile'], [], $options);
  return $batch;
}
