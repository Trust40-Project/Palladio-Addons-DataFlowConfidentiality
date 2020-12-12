package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.util;

import java.util.function.Consumer;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.Notifier;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EContentAdapter;

public class LabelFeatureMonitoringAdapter extends EContentAdapter {

    @Override
    public void setTarget(Notifier target) {
        super.setTarget(target);
    }

    @Override
    public void unsetTarget(Notifier target) {
        super.unsetTarget(target);
    }

    public static void handleFeatureChange(Notification notification, Consumer<Notification> notificationCallback) {
        if (notification.getEventType() == Notification.SET || notification.getEventType() == Notification.UNSET) {
            var oldValue = notification.getOldValue();
            if (oldValue instanceof EObject) {
                ((EObject) oldValue).eAdapters()
                    .removeIf(LabelFeatureMonitoringAdapter.class::isInstance);
            }
            var newValue = notification.getNewValue();
            if (newValue instanceof EObject) {
                ((EObject) newValue).eAdapters()
                    .add(new LabelFeatureMonitoringAdapter() {
                        @Override
                        public void notifyChanged(Notification notification) {
                            notificationCallback.accept(notification);
                            super.notifyChanged(notification);
                        }
                    });
            }
        }
    }

}
