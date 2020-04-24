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

public class SeffReturnCharacteristicReferenceItemProvider extends SeffReturnCharacteristicReferenceItemProviderGen
        implements DataTypeToNameMixin {

	public SeffReturnCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}
	
	@Override
	public String getText(Object object) {
		SeffReturnCharacteristicReference ref = (SeffReturnCharacteristicReference) object;
		String characteristicTypeName = Optional.ofNullable(ref.getCharacteristicType()).map(CharacteristicType::getName).orElse("*");
	    Optional<String> characteristicLiteralName = Optional.ofNullable(ref.getLiteral()).map(Literal::getName);
	    Optional<String> characteristicDataTypeName = Optional.ofNullable(ref.getDataType()).map(this::getName);
	    String characteristicValueName = characteristicLiteralName.orElse(characteristicDataTypeName.orElse("*"));
		return String.format("SEFF.result.%s.%s", characteristicTypeName, characteristicValueName);
	}
	
	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case ExpressionsPackage.SEFF_RETURN_CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE:
			case ExpressionsPackage.SEFF_RETURN_CHARACTERISTIC_REFERENCE__LITERAL:
			case ExpressionsPackage.SEFF_RETURN_CHARACTERISTIC_REFERENCE__DATA_TYPE:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}
	
}
