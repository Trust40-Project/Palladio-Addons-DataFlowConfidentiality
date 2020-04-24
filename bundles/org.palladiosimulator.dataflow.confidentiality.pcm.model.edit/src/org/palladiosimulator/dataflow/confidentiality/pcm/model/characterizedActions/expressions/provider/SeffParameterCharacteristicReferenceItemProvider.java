package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.provider;

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
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.expressions.SeffParameterCharacteristicReference;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ContainingSeffFinderMixin;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ItemPropertyDescriptorDecorator;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;
import org.palladiosimulator.pcm.repository.OperationSignature;
import org.palladiosimulator.pcm.repository.Parameter;
import org.palladiosimulator.pcm.seff.ServiceEffectSpecification;

public class SeffParameterCharacteristicReferenceItemProvider extends SeffParameterCharacteristicReferenceItemProviderGen
	implements ContainingSeffFinderMixin, DataTypeToNameMixin {

	public SeffParameterCharacteristicReferenceItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void addParameterPropertyDescriptor(Object object) {
		super.addParameterPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				return getContainingServiceEffectSpecification((EObject)thisObject)
						.map(ServiceEffectSpecification::getDescribedService__SEFF)
						.filter(OperationSignature.class::isInstance)
						.map(OperationSignature.class::cast)
						.map(OperationSignature::getParameters__OperationSignature)
						.map(Collections::unmodifiableCollection)
						.map(Collection.class::cast)
						.orElseGet(() -> super.getChoiceOfValues(thisObject));
			}

		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	public String getText(Object object) {
		SeffParameterCharacteristicReference ref = (SeffParameterCharacteristicReference) object;
		String parameterName = Optional.ofNullable(ref.getParameter()).map(Parameter::getParameterName).orElse("null");
		String characteristicTypeName = Optional.ofNullable(ref.getCharacteristicType()).map(CharacteristicType::getName).orElse("*");
	    Optional<String> characteristicLiteralName = Optional.ofNullable(ref.getLiteral()).map(Literal::getName);
	    Optional<String> characteristicDataTypeName = Optional.ofNullable(ref.getDataType()).map(this::getName);
	    String characteristicValueName = characteristicLiteralName.orElse(characteristicDataTypeName.orElse("*"));
		return String.format("SEFF.%s.%s.%s", parameterName, characteristicTypeName, characteristicValueName);
	}
	
	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case ExpressionsPackage.SEFF_PARAMETER_CHARACTERISTIC_REFERENCE__CHARACTERISTIC_TYPE:
			case ExpressionsPackage.SEFF_PARAMETER_CHARACTERISTIC_REFERENCE__LITERAL:
			case ExpressionsPackage.SEFF_PARAMETER_CHARACTERISTIC_REFERENCE__PARAMETER:
			case ExpressionsPackage.SEFF_PARAMETER_CHARACTERISTIC_REFERENCE__DATA_TYPE:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}
	
}
