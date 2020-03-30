package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Collection;
import java.util.Collections;
import java.util.Optional;
import java.util.stream.Collectors;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedEntryLevelSystemCall;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ItemPropertyDescriptorDecorator;
import org.palladiosimulator.pcm.core.provider.PalladioComponentModelEditPlugin;
import org.palladiosimulator.pcm.repository.OperationInterface;
import org.palladiosimulator.pcm.repository.OperationProvidedRole;
import org.palladiosimulator.pcm.repository.ProvidedRole;

public class CharacterizedEntryLevelSystemCallItemProvider extends CharacterizedEntryLevelSystemCallItemProviderGen {

	public CharacterizedEntryLevelSystemCallItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void addOperationSignature__EntryLevelSystemCallPropertyDescriptor(Object object) {
		super.addOperationSignature__EntryLevelSystemCallPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				return Optional.ofNullable(thisObject)
						.filter(CharacterizedEntryLevelSystemCall.class::isInstance)
						.map(CharacterizedEntryLevelSystemCall.class::cast)
						.map(CharacterizedEntryLevelSystemCall::getProvidedRole_EntryLevelSystemCall)
						.map(OperationProvidedRole::getProvidedInterface__OperationProvidedRole)
						.map(OperationInterface::getSignatures__OperationInterface)
						.map(Collections::unmodifiableCollection)
						.map(Collection.class::cast)
						.orElseGet(() -> super.getChoiceOfValues(thisObject));
			}
			
		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	protected void addProvidedRole_EntryLevelSystemCallPropertyDescriptor(Object object) {
		super.addProvidedRole_EntryLevelSystemCallPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				return super.getChoiceOfValues(thisObject)
						.stream()
						.filter(ProvidedRole.class::isInstance)
						.map(ProvidedRole.class::cast)
						.filter(pr -> pr.getProvidingEntity_ProvidedRole() instanceof org.palladiosimulator.pcm.system.System)
						.collect(Collectors.toList());
			}
			
		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	public String getText(Object object) {
		return Optional.ofNullable(object)
				.filter(CharacterizedEntryLevelSystemCall.class::isInstance)
				.map(CharacterizedEntryLevelSystemCall.class::cast)
				.map(CharacterizedEntryLevelSystemCall::getEntityName)
				.map(name -> getString("_UI_CharacterizedEntryLevelSystemCall_type") + " " + name)
				.orElse(super.getText(object));
	}

	@Override
	public Object getImage(Object object) {
		return Optional.ofNullable(PalladioComponentModelEditPlugin.INSTANCE)
				.map(PalladioComponentModelEditPlugin::getPluginResourceLocator)
				.map(l -> l.getImage("full/obj16/EntryLevelSystemCall"))
				.map(img -> this.overlayImage(object, img))
				.orElseGet(() -> super.getImage(object));
	}
	
}
