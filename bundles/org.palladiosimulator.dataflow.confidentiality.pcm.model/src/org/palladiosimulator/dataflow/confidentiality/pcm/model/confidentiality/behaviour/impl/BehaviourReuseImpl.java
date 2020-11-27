package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Optional;

import org.eclipse.emf.common.util.BasicEList.UnmodifiableEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.VariableBinding;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.impl.NamedReferenceUtils;
import org.palladiosimulator.pcm.parameter.VariableUsage;

import de.uka.ipd.sdq.stoex.AbstractNamedReference;

public class BehaviourReuseImpl extends BehaviourReuseImplGen {

    @Override
    public EList<VariableUsage> getVariableUsages() {
        var cachedList = super.getVariableUsages();
        cachedList.clear();
        for (VariableUsage variableUsage : getReusedBehaviour().getVariableUsages()) {
            var instantiatedVariableUsage = EcoreUtil.copy(variableUsage);
            bindVariables(instantiatedVariableUsage, getVariableBindings());
            cachedList.add(instantiatedVariableUsage);
        }
        return new UnmodifiableEList<>(cachedList.size(), cachedList.toArray());
    }

    protected void bindVariables(VariableUsage variableUsage, Collection<VariableBinding> variableBindings) {
        for (AbstractNamedReference referenceToReplace : findAllChildrenOfType(variableUsage, AbstractNamedReference.class)) {
            getBoundReference(referenceToReplace).map(EcoreUtil::copy).ifPresent(replacement -> {
                EcoreUtil.replace(referenceToReplace, replacement);
            });
        }
    }
    
    protected Optional<AbstractNamedReference> getBoundReference(AbstractNamedReference reference) {
        var referenceName = NamedReferenceUtils.toString(reference);
        for (VariableBinding binding : getVariableBindings()) {
            var templateReferenceName = NamedReferenceUtils.toString(binding.getBoundVariable());
            if (referenceName.equals(templateReferenceName)) {
                return Optional.of(binding.getBoundValue());
            }
        }
        return Optional.empty();
    }
    
    @SuppressWarnings("unchecked")
    protected static <T extends EObject> Collection<T> findAllChildrenOfType(EObject node, Class<T> type) {
        final Collection<T> result = new ArrayList<>();
        node.eAllContents().forEachRemaining(child -> {
            if (type.isInstance(child)) {
                result.add((T) child);
            }
        });
        return result;
    }

}
