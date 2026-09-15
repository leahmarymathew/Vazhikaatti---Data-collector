# Vazhikatti Data Contract

This is the canonical field contract for Flutter local records, JSON/CSV exports, and future FastAPI schemas. The current Flutter application does not call the backend.

## Identity

`image_id`, `filename`, `dataset_split`, `capture_session_id`, `capture_type`, `frame_index`, `timestamp`, `collector_id`, `checksum`

## Campus and hierarchy

`campus_id`, `campus_name`, `building_id`, `building_name`, `wing_id`, `wing_name`, `floor_id`, `floor_number`, `area_id`, `area_type`, `room_id`, `room_name`

## Indoor navigation

`node_id`, `node_type`, `node_name`, `local_x`, `local_y`, `local_z`, `coordinate_system_id`, `previous_node_id`, `next_node_id`, `connected_nodes`

## GPS

`latitude`, `longitude`, `altitude`, `gps_accuracy`, `gps_timestamp`, `location_source`

## Orientation

`heading`, `pitch`, `roll`, `direction`, `view_angle`, `camera_facing`, `view_direction`

## Camera and EXIF

`device_make`, `device_model`, `camera_id`, `image_width`, `image_height`, `focal_length`, `focal_length_35mm`, `ISO`, `exposure_time`, `aperture`, `white_balance`, `flash_used`

## Scene

`lighting_condition`, `crowd_level`, `occlusion_level`, `artificial_light`, `natural_light`, `scene_condition`

## Panorama

`panorama_id`, `panorama_sequence_id`, `overlap_group_id`, `frame_index`, `is_panorama_source`, `panorama_status`

## Quality

`blur_score`, `brightness_score`, `contrast_score`, `noise_score`, `quality_score`, `is_blurry`, `is_usable`, `preprocessing_version`

## Future CV fields

`feature_method`, `keypoint_count`, `descriptor_dimension`, `descriptor_file`, `reference_image_id`, `matching_method`, `total_matches`, `good_matches`, `ratio_test_threshold`, `match_score`, `geometric_model`, `ransac_threshold`, `ransac_iterations`, `inlier_count`, `inlier_ratio`, `homography_valid`

## Ground truth (collector-entered)

`ground_truth_campus`, `ground_truth_building`, `ground_truth_floor`, `ground_truth_node_name` are entered explicitly by the collector on the capture screen via restricted dropdowns (campus/building/floor) and free text (node name). They are required at capture time and are distinct from the automatically captured GPS/orientation fields above.

Canonical values: campus is `IIIT K`; building is one of `Old Academic Block`, `New Academic Block`, `Admin Block`, `General Pathway`; floor is one of `Basement`, `Ground`, `1`, `2`. Values are stored exactly as selected, never abbreviated.

## Future localization fields

`ground_truth_node`, `ground_truth_local_x`, `ground_truth_local_y`, `predicted_building`, `predicted_floor`, `predicted_node`, `predicted_local_x`, `predicted_local_y`, `localization_confidence`, `position_error_m`, `building_correct`, `floor_correct`, `node_correct`, `query_time_ms`

These depend on the future node graph. They stay null unless populated by a future feature; the current capture UI does not collect or validate them.

All fields are nullable unless required by the capture validation policy. Missing sensor/EXIF values stay null; they are never fabricated. CSV headers and JSON keys use these exact spellings, including `ISO`.

## Flow

```text
Flutter typed metadata -> SQLite/local JSON -> offline JSON/CSV export -> future FastAPI request
```

The backend is intentionally a separate future service. No Flutter dependency points at it in the current version.
