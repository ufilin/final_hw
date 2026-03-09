resource "yandex_container_registry" "ufilin" {
  name      = "ufilin-registry"
  folder_id = var.folder_id
  labels = {
    my-label = "registry_for_final_hw"
  }
}