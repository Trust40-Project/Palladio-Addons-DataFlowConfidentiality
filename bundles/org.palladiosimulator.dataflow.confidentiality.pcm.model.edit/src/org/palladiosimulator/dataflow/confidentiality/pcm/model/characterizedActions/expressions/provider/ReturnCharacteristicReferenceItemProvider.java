package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedExternalCallAction;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ExpressionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ReturnCharacteristicReference;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.AvailableEntryLevelSystemCallActionMixin;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.AvailableExternalCallActionMixin;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;
import org.palladiosimulator.pcm.seff.ExternalCallAction;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public class ReturnCharacteristicReferenceItemProvider extends ReturnCharacteristicReferenceItemProviderGen
	implements AvailableExternalCallActionMixin, AvailableEntryLevelSystemCallActionMixin, DataTypeToNameMixin {

	public ReturnCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void addExternalCallActionPropertyDescriptor(Object object) {
		super.addExternalCallActionPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		IItemPropertyDescriptor decorator = getAvailableExternalCallActionsPropertyDescriptor(originalItemDescriptor);
		itemPropertyDescriptors.add(decorator);
	}
	
	@Override
	protected void addEntryLevelSystemCallPropertyDescriptor(Object object) {
		super.addEntryLevelSystemCallPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		IItemPropertyDescriptor decorator = getAvailableEntryLevelSystemCallsPropertyDescriptor(originalItemDescriptor);
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	public String getText(Object object) {
		ReturnCharacteristicReference ref = (ReturnCharacteristicReference)object;
		Optional<String> ecaName = Optional.ofNullable(ref.getExternalCallAction()).map(ExternalCallAction::getEntityName);
		Optional<String> elscName = Optional.ofNullable(ref.getEntryLevelSystemCall()).map(EntryLevelSystemCall::getEntityName);
		String actionName = ecaName.orElse(elscName.orElse("null"));
		String characteristicTypeName = Optional.ofNullable(ref.getCharacteristicType()).map(CharacteristicType::getName).orElse("*");
        Optional<String> characteristicLiteralName = Optional.ofNullable(ref.getLiteral()).map(Literal::getName);
        Optional<String> characteristicDataTypeName = Optional.ofNullable(ref.getDataType()).map(this::getName);
        String characteristicValueName = characteristicLiteralName.orElse(characteristicDataTypeName.orElse("*"));
		return String.format("%s.result.%s.%s", actionName, characteristicTypeName, characteristicValueName);
	}
	
	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case ExpressionsPackage.RETURN_CHARACTERISTIC_REFERENCE__ENTRY_LEVEL_SYSTEM_CALL:
			case ExpressionsPackage.RETURN_CHARACTERISTIC_REFERENCE__EXTERNAL_CALL_ACTION:
			case ExpressionsPackage.RETURN_CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE:
			case ExpressionsPackage.RETURN_CHARACTERISTIC_REFERENCE__LITERAL:
			case ExpressionsPackage.PARAMETER_CHARACTERISTIC_REFERENCE__DATA_TYPE:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}
}
