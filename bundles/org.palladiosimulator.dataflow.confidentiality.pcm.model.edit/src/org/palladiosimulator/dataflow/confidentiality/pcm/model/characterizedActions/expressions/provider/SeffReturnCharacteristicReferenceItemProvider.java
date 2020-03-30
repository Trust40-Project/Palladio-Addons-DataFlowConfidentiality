package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedExternalCallAction;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ExpressionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.SeffReturnCharacteristicReference;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;

public class SeffReturnCharacteristicReferenceItemProvider extends SeffReturnCharacteristicReferenceItemProviderGen {

	public SeffReturnCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}
	
	@Override
	public String getText(Object object) {
		SeffReturnCharacteristicReference ref = (SeffReturnCharacteristicReference) object;
		String characteristicTypeName = Optional.ofNullable(ref.getCharacteristicType()).map(CharacteristicType::getName).orElse("*");
		String characteristicValueName = Optional.ofNullable(ref.getLiteral()).map(Literal::getName).orElse("*");
		return String.format("SEFF.result.%s.%s", characteristicTypeName, characteristicValueName);
	}
	
	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case ExpressionsPackage.SEFF_RETURN_CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE:
			case ExpressionsPackage.SEFF_RETURN_CHARACTERISTIC_REFERENCE__LITERAL:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}
	
}
