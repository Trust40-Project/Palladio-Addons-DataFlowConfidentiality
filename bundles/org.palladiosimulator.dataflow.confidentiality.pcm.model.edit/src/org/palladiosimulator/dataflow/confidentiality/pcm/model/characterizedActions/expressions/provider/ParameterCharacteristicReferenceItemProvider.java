package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.provider;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedExternalCallAction;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ExpressionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.ParameterCharacteristicReference;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.AvailableEntryLevelSystemCallActionMixin;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.AvailableExternalCallActionMixin;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ItemPropertyDescriptorDecorator;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;
import org.palladiosimulator.pcm.repository.OperationSignature;
import org.palladiosimulator.pcm.repository.Parameter;
import org.palladiosimulator.pcm.seff.ExternalCallAction;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public class ParameterCharacteristicReferenceItemProvider extends ParameterCharacteristicReferenceItemProviderGen
		implements AvailableExternalCallActionMixin, AvailableEntryLevelSystemCallActionMixin {

	public ParameterCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void addParameterPropertyDescriptor(Object object) {
		super.addParameterPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				EObject eobject = (EObject) thisObject;
				Optional<OperationSignature> signature1 = getContainingEntryLevelSystemCall(eobject)
						.map(EntryLevelSystemCall::getOperationSignature__EntryLevelSystemCall);
				Optional<OperationSignature> signature2 = getContainingExternalCallAction(eobject)
						.map(ExternalCallAction::getCalledService_ExternalService);
				Optional<OperationSignature> signature = Optional
						.ofNullable(signature1.orElse(signature2.orElse(null)));
				return signature.map(OperationSignature::getParameters__OperationSignature).map(Collection.class::cast).orElse(Collections.emptyList());
			}

		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	protected void addExternalCallActionPropertyDescriptor(Object object) {
		super.addExternalCallActionPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object object) {
				return getContainingExternalCallAction((EObject)object).map(Arrays::asList).orElse(Collections.emptyList());
			}
			
		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	protected void addEntryLevelSystemCallPropertyDescriptor(Object object) {
		super.addEntryLevelSystemCallPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object object) {
				return getContainingEntryLevelSystemCall((EObject)object).map(Arrays::asList).orElse(Collections.emptyList());
			}
			
		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	public String getText(Object object) {
		ParameterCharacteristicReference ref = (ParameterCharacteristicReference)object;
		Optional<String> ecaName = Optional.ofNullable(ref.getExternalCallAction()).map(ExternalCallAction::getEntityName);
		Optional<String> elscName = Optional.ofNullable(ref.getEntryLevelSystemCall()).map(EntryLevelSystemCall::getEntityName);
		String actionName = ecaName.orElse(elscName.orElse("null"));
		String parameterName = Optional.ofNullable(ref.getParameter()).map(Parameter::getParameterName).orElse("null");
		String characteristicTypeName = Optional.ofNullable(ref.getCharacteristicType()).map(CharacteristicType::getName).orElse("*");
		String characteristicValueName = Optional.ofNullable(ref.getLiteral()).map(Literal::getName).orElse("*");
		return String.format("%s.%s.%s.%s", actionName, parameterName, characteristicTypeName, characteristicValueName);
	}
	
	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case ExpressionsPackage.PARAMETER_CHARACTERISTIC_REFERENCE__ENTRY_LEVEL_SYSTEM_CALL:
			case ExpressionsPackage.PARAMETER_CHARACTERISTIC_REFERENCE__EXTERNAL_CALL_ACTION:
			case ExpressionsPackage.PARAMETER_CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE:
			case ExpressionsPackage.PARAMETER_CHARACTERISTIC_REFERENCE__LITERAL:
			case ExpressionsPackage.PARAMETER_CHARACTERISTIC_REFERENCE__PARAMETER:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}

}
