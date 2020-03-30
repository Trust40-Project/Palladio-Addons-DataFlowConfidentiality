package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedActionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedExternalCallAction;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedResourceDemandingSEFF;
import org.palladiosimulator.pcm.core.provider.PalladioComponentModelEditPlugin;
import org.palladiosimulator.pcm.repository.Signature;

public class CharacterizedResourceDemandingSEFFItemProvider extends CharacterizedResourceDemandingSEFFItemProviderGen {

	public CharacterizedResourceDemandingSEFFItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	public String getText(Object object) {
		var seff = (CharacterizedResourceDemandingSEFF) object;
		var signatureName = Optional.ofNullable(seff.getDescribedService__SEFF()).map(Signature::getEntityName);
		if (signatureName.isPresent()) {
			return String.format("%s %s (%s)", getString("_UI_CharacterizedResourceDemandingSEFF_type"),
					signatureName.get(), seff.getId());
		}
		return super.getText(object);
	}

	@Override
	public Object getImage(Object object) {
		return Optional.ofNullable(PalladioComponentModelEditPlugin.INSTANCE)
				.map(PalladioComponentModelEditPlugin::getPluginResourceLocator)
				.map(l -> l.getImage("full/obj16/ResourceDemandingSEFF"))
				.map(img -> this.overlayImage(object, img))
				.orElseGet(() -> super.getImage(object));
	}
	
	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case CharacterizedActionsPackage.CHARACTERIZED_RESOURCE_DEMANDING_SEFF__DESCRIBED_SERVICE_SEFF:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}

}