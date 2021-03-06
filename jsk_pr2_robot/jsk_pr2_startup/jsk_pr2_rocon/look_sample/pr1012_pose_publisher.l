#!/usr/bin/env roseus
(ros::roseus "look_sample")
(require "models/room73b2-scene.l")
(load "package://pr2eus/pr2-interface.l")

(ros::load-ros-manifest "geometry_msgs")
(pr2-init)
(room73b2)

(unless (boundp '*tfl*) (setq *tfl* (instance transform-listener :init)))
(defun sync-pr2-pos-73b2 ()
  (setq pr2-trans (send *tfl* :lookup-transform "/eng2/7f/73B2" "/base_footprint" (ros::time 0)))
  (send *pr2* :reset-coords)
  (send *pr2* :transform pr2-trans :world)
  )
(sync-pr2-pos-73b2)

(objects (list *pr2* *room73b2*))
(ros::advertise "/pr1012_head_pos_from_73b2_in_pr2" geometry_msgs::PoseStamped 1)

(ros::rate 5)
(ros::ros-info "Publish to /pr1012_head_pos_from_73b2_in_pr2 Start!")
(while (ros::ok)
  (let* ((new-head-pose (send *tfl* :lookup-transform "/eng2/7f/73B2" "/head_tilt_link" (ros::time 0)))
         (pr1012-head-pose-msg (ros::coords->tf-pose-stamped (make-coords :coords new-head-pose) "/eng2/7f/73B2")))
    (ros::publish "/pr1012_head_pos_from_73b2_in_pr2" pr1012-head-pose-msg)
    (send *irtviewer* :draw-objects)
    )
  (ros::sleep)
  )
