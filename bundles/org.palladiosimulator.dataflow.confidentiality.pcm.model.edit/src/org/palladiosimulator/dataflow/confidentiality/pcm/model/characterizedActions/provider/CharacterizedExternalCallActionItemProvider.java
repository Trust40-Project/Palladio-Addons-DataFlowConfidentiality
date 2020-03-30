package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Collection;
import java.util.Collections;
import java.util.Optional;
import java.util.stream.Collectors;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.edit.provider.IItemPropertyDescriptor;
import org.eclipse.emf.edit.provider.ViewerNotification;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedActionsPackage;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedExternalCallAction;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ContainingSeffFinderMixin;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ContainmentWalker;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider.util.ItemPropertyDescriptorDecorator;
import org.palladiosimulator.pcm.core.provider.PalladioComponentModelEditPlugin;
import org.palladiosimulator.pcm.repository.BasicComponent;
import org.palladiosimulator.pcm.repository.OperationInterface;
import org.palladiosimulator.pcm.repository.OperationRequiredRole;
import org.palladiosimulator.pcm.repository.OperationSignature;
import org.palladiosimulator.pcm.repository.RequiredRole;
import org.palladiosimulator.pcm.seff.AbstractAction;
import org.palladiosimulator.pcm.seff.ServiceEffectSpecification;

public class CharacterizedExternalCallActionItemProvider extends CharacterizedExternalCallActionItemProviderGen
	implements ContainingSeffFinderMixin {

	public CharacterizedExternalCallActionItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	@Override
	protected void addCalledService_ExternalServicePropertyDescriptor(Object object) {
		super.addCalledService_ExternalServicePropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				Collection<?> originalChoice = super.getChoiceOfValues(thisObject);
				if (thisObject instanceof CharacterizedExternalCallAction) {
					CharacterizedExternalCallAction action = (CharacterizedExternalCallAction)thisObject;
					 Optional<Collection<OperationSignature>> foundRoles = getAvailableSignatures(action);
					if (foundRoles.isPresent()) {
						return foundRoles.get();
					}
				}
				return originalChoice;
			}
			
		};
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	protected void addRole_ExternalServicePropertyDescriptor(Object object) {
		super.addRole_ExternalServicePropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		ItemPropertyDescriptorDecorator decorator = new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				Collection<?> originalChoice = super.getChoiceOfValues(thisObject);
				if (thisObject instanceof CharacterizedExternalCallAction) {
					CharacterizedExternalCallAction action = (CharacterizedExternalCallAction)thisObject;
					Optional<Collection<RequiredRole>> foundRoles = getAvailableRequiredRoles(action);
					if (foundRoles.isPresent()) {
						return foundRoles.get();
					}
				}
				return originalChoice;
			}
			
		};
		itemPropertyDescriptors.add(decorator);
	}

	
	
	@Override
	protected void addPredecessor_AbstractActionPropertyDescriptor(Object object) {
		super.addPredecessor_AbstractActionPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		IItemPropertyDescriptor decorator = createActionPropertyDescriptor(originalItemDescriptor);
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	protected void addSuccessor_AbstractActionPropertyDescriptor(Object object) {
		super.addSuccessor_AbstractActionPropertyDescriptor(object);
		IItemPropertyDescriptor originalItemDescriptor = itemPropertyDescriptors.remove(itemPropertyDescriptors.size() - 1);
		IItemPropertyDescriptor decorator = createActionPropertyDescriptor(originalItemDescriptor);
		itemPropertyDescriptors.add(decorator);
	}

	@Override
	public void notifyChanged(Notification notification) {
		super.notifyChanged(notification);
		
		switch (notification.getFeatureID(CharacterizedExternalCallAction.class))
		{
			case CharacterizedActionsPackage.CHARACTERIZED_EXTERNAL_CALL_ACTION__ENTITY_NAME:
				fireNotifyChanged(new ViewerNotification(notification, notification.getNotifier(), false, true));
				return;
		}
	}

	@Override
	public String getText(Object object) {
		return Optional.ofNullable(object)
				.filter(CharacterizedExternalCallAction.class::isInstance)
				.map(CharacterizedExternalCallAction.class::cast)
				.map(CharacterizedExternalCallAction::getEntityName)
				.map(name -> getString("_UI_CharacterizedExternalCallAction_type") + " " + name)
				.orElse(super.getText(object));
	}
	
	@Override
	public Object getImage(Object object) {
		return Optional.ofNullable(PalladioComponentModelEditPlugin.INSTANCE)
				.map(PalladioComponentModelEditPlugin::getPluginResourceLocator)
				.map(l -> l.getImage("full/obj16/ExternalCallAction"))
				.map(img -> this.overlayImage(object, img))
				.orElseGet(() -> super.getImage(object));
	}

	protected IItemPropertyDescriptor createActionPropertyDescriptor(IItemPropertyDescriptor originalItemDescriptor) {
		return new ItemPropertyDescriptorDecorator(originalItemDescriptor) {

			@Override
			public Collection<?> getChoiceOfValues(Object thisObject) {
				Collection<?> originalChoice = super.getChoiceOfValues(thisObject);
				if (thisObject instanceof CharacterizedExternalCallAction) {
					CharacterizedExternalCallAction action = (CharacterizedExternalCallAction)thisObject;
					Optional<Collection<AbstractAction>> foundActions = getAvailableActions(action);
					if (foundActions.isPresent()) {
						return foundActions.get();
					}
				}
				return originalChoice;
			}
			
		};
	}

	protected Optional<Collection<AbstractAction>> getAvailableActions(CharacterizedExternalCallAction action) {
		return getContainingServiceEffectSpecification(action)
			.map(ContainmentWalker::new)
			.map(cw -> cw.findChildrenOfType(AbstractAction.class));
	}
	
	protected Optional<Collection<OperationSignature>> getAvailableSignatures(CharacterizedExternalCallAction action) {
		return getAvailableRequiredRoles(action)
				.map(Collection::stream)
				.map(s -> s
						.filter(OperationRequiredRole.class::isInstance)
						.map(OperationRequiredRole.class::cast)
						.map(OperationRequiredRole::getRequiredInterface__OperationRequiredRole)
						.map(OperationInterface::getSignatures__OperationInterface)
						.flatMap(Collection::stream)
						.collect(Collectors.toList())
				);
	}
	
	protected Optional<Collection<RequiredRole>> getAvailableRequiredRoles(CharacterizedExternalCallAction action) {
		return getContainingServiceEffectSpecification(action)
				.map(ServiceEffectSpecification::getBasicComponent_ServiceEffectSpecification)
				.map(BasicComponent::getRequiredRoles_InterfaceRequiringEntity)
				.map(Collections::unmodifiableCollection);
	}
	
}
