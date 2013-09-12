/*
**  Copyright (C) 2013 Aldebaran Robotics
**  See COPYING for the license
*/
#include "pyproperty.hpp"
#include <boost/python.hpp>
#include <qitype/property.hpp>
#include <qitype/anyobject.hpp>
namespace qi { namespace py {

    class PyProperty : public qi::GenericProperty {
    public:
      PyProperty(const std::string &signature)
        : qi::GenericProperty(qi::TypeInterface::fromSignature(signature))
      {
      }

      ~PyProperty() {
      }

      boost::python::object val() const {
        return value().to<boost::python::object>();
      }

      //change the name to avoid warning "hidden overload in base class" : YES WE KNOW :)
      void setVal(boost::python::object obj) {
        qi::GenericProperty::setValue(qi::AnyReference(obj));
      }
    };

    class PyProxyProperty {
    public:
      PyProxyProperty(qi::AnyObject obj, const qi::MetaProperty &signal)
        : _obj(obj)
        , _sigid(signal.uid()){
      }

      //TODO: support async
      boost::python::object value() const {
        return _obj->property(_sigid).value().to<boost::python::object>();
      }

      //TODO: support async
      void setValue(boost::python::object obj) {
        _obj->setProperty(_sigid, qi::AnyValue::from(obj));
      }

    private:
      qi::AnyObject _obj;
      unsigned int  _sigid;
    };

    boost::python::object makePyProperty(const std::string &signature) {
      return boost::python::object(PyProperty(signature));
    }

    qi::PropertyBase *getProperty(boost::python::object obj) {
      return boost::python::extract<PyProperty*>(obj);
    }

    boost::python::object makePyProxyProperty(const qi::AnyObject &obj, const qi::MetaProperty &prop) {
      return boost::python::object(PyProxyProperty(obj, prop));
    }

    void export_pyproperty() {
      boost::python::class_<PyProperty>("Property", boost::python::init<const std::string &>())
          .def("value", &PyProperty::val,
               "value() -> value\n"
               ":return: the value stored inside the property")

          .def("setValue", &PyProperty::setVal, (boost::python::arg("value")),
               "setValue(value) -> None\n"
               ":param value: the value of the property\n"
               "\n"
               "set the value of the property");

      boost::python::class_<PyProxyProperty>("_ProxyProperty", boost::python::no_init)
          .def("value", &PyProxyProperty::value)
          .def("setValue", &PyProxyProperty::setValue, (boost::python::arg("value")));
    }

  }
}
