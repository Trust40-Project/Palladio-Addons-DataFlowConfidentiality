package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto;

import java.util.Collection;
import java.util.Iterator;
import java.util.stream.Collectors;

import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance;

import com.google.common.base.Objects;

import de.uka.ipd.sdq.identifier.Identifier;

public class EntityInstanceImpl implements EntityInstance {

    private final Identifier entity;
    private final Collection<Identifier> context;

    public EntityInstanceImpl(Identifier entity, Collection<Identifier> context) {
        this.entity = entity;
        this.context = context;
    }

    @Override
    public Identifier getEntity() {
        return entity;
    }

    @Override
    public Collection<Identifier> getContext() {
        return context;
    }

    public String toString() {
        String result = "";
        result += "Entity: " + entity.getId() + System.lineSeparator();
        result += "Context:";
        result += context.stream()
            .map(Identifier::getId)
            .collect(Collectors.joining(System.lineSeparator() + "\t", System.lineSeparator() + "\t", ""));
        return result;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((context == null) ? 0
                : context.stream()
                    .map(Identifier::getId)
                    .collect(Collectors.toList())
                    .hashCode());
        result = prime * result + ((entity == null || entity.getId() == null) ? 0
                : entity.getId()
                    .hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        EntityInstanceImpl other = (EntityInstanceImpl) obj;
        if (context == null) {
            if (other.context != null)
                return false;
        } else if (!equals(context, other.context))
            return false;
        if (entity == null) {
            if (other.entity != null)
                return false;
        } else if (!equals(entity, other.entity))
            return false;
        return true;
    }

    private static boolean equals(Identifier i1, Identifier i2) {
        return Objects.equal(i1.getId(), i2.getId());
    }

    private static boolean equals(Collection<Identifier> i1, Collection<Identifier> i2) {
        if (i1.size() != i2.size()) {
            return false;
        }
        Iterator<Identifier> i1Iter = i1.iterator();
        Iterator<Identifier> i2Iter = i2.iterator();
        while (i1Iter.hasNext()) {
            if (!Objects.equal(i1Iter.next()
                .getId(), i2Iter.next().getId())) {
                return false;
            }
        }
        return true;
    }

}
