/*
 *
 * (C) 2013-22 - ntop.org
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#ifndef _OPERATING_SYSTEM_H_
#define _OPERATING_SYSTEM_H_

// #define AS_LATENCY_DEBUG 1

#include "ntop_includes.h"

class OperatingSystem : public GenericHashEntry, public GenericTrafficElement, public SerializableElement {
 private:
  OSType os_type;

  inline void incSentStats(time_t t, u_int64_t num_pkts, u_int64_t num_bytes)  {
    if(first_seen == 0) first_seen = t,
    last_seen = iface->getTimeLastPktRcvd();
    sent.incStats(t, num_pkts, num_bytes);
  }
  inline void incRcvdStats(time_t t,u_int64_t num_pkts, u_int64_t num_bytes) {
    rcvd.incStats(t, num_pkts, num_bytes);
  }

 public:
  OperatingSystem(NetworkInterface *_iface, OSType os);
  ~OperatingSystem();

  void set_hash_entry_state_idle();

  inline u_int16_t getNumHosts()                 { return getUses();           }
  inline u_int32_t key()                         { return(os_type);            }
  inline OSType get_os_type()                    { return(os_type);            }

  bool equal(OSType os);

  inline void incStats(time_t when, u_int16_t proto_id,
		       u_int64_t sent_packets, u_int64_t sent_bytes,
		       u_int64_t rcvd_packets, u_int64_t rcvd_bytes) {
    if(ndpiStats || (ndpiStats = new nDPIStats()))
      ndpiStats->incStats(when, proto_id, sent_packets, sent_bytes, rcvd_packets, rcvd_bytes);
    incSentStats(when, sent_packets, sent_bytes);
    incRcvdStats(when, rcvd_packets, rcvd_bytes);
  }

  void lua(lua_State* vm, DetailsLevel details_level, bool asListElement);

  inline void deserialize(json_object *obj) {
    GenericHashEntry::deserialize(obj);
    GenericTrafficElement::deserialize(obj, iface);
  }
  inline void serialize(json_object *obj, DetailsLevel details_level) {
    GenericHashEntry::getJSONObject(obj, details_level);
    GenericTrafficElement::getJSONObject(obj, iface);
  }
  inline char* getSerializationKey(char *buf, uint bufsize) { snprintf(buf, bufsize, AS_SERIALIZED_KEY, iface->get_id(), os_type); return(buf); }
};

#endif /* _AUTONOMOUS_SYSTEM_H_ */

